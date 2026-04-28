import 'dotenv/config';
import * as tts from '@google-cloud/text-to-speech';
import { XMLParser } from 'fast-xml-parser';
import * as fs from 'fs';
import * as path from 'path';

const BOOKS_DIR = path.resolve(process.env.BOOKS_DIR ?? path.join(__dirname, '..', 'books'));

const client = new tts.TextToSpeechClient();

const VOICE_CONFIG: Record<string, { languageCode: string; name: string }> = {
  ja: { languageCode: 'ja-JP', name: 'ja-JP-Wavenet-B' },
  en: { languageCode: 'en-US', name: 'en-US-Wavenet-C' },
};

async function synthesize(text: string, lang: 'ja' | 'en'): Promise<Buffer> {
  const voice = VOICE_CONFIG[lang];
  const [response] = await client.synthesizeSpeech({
    input: { text },
    voice,
    audioConfig: { audioEncoding: 'MP3' },
  });
  if (!response.audioContent) throw new Error(`No audio content for: ${text}`);
  return Buffer.from(response.audioContent as Uint8Array);
}

function ensureDir(dir: string): void {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function toArray<T>(value: T | T[] | undefined): T[] {
  if (value === undefined) return [];
  return Array.isArray(value) ? value : [value];
}

interface TextNode {
  ja: string;
  en: string;
}

interface PageNode {
  text: TextNode | TextNode[];
}

interface ChoiceNode {
  ja: string;
  en: string;
}

interface QuestionNode {
  text: TextNode;
  choices: { choice: ChoiceNode | ChoiceNode[] };
}

interface EhonXml {
  ehon: {
    page: PageNode | PageNode[];
    questions?: { question: QuestionNode | QuestionNode[] };
  };
}

async function generateForBook(bookId: string): Promise<void> {
  const xmlPath = path.join(BOOKS_DIR, bookId, 'book.xml');
  if (!fs.existsSync(xmlPath)) {
    console.warn(`  book.xml not found: ${xmlPath}`);
    return;
  }

  const audiosDir = path.join(BOOKS_DIR, bookId, 'audios');
  ensureDir(audiosDir);

  const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: '@_' });
  const xml = parser.parse(fs.readFileSync(xmlPath, 'utf-8')) as EhonXml;

  const pages = toArray(xml.ehon.page);
  for (let pi = 0; pi < pages.length; pi++) {
    const texts = toArray(pages[pi].text);
    for (let ti = 0; ti < texts.length; ti++) {
      const prefix = `page${pi + 1}_text${ti + 1}`;
      for (const lang of ['ja', 'en'] as const) {
        const text = texts[ti][lang];
        const file = path.join(audiosDir, `${prefix}_${lang}.mp3`);
        console.log(`  ${prefix}_${lang}: "${text}"`);
        const audio = await synthesize(text, lang);
        fs.writeFileSync(file, audio);
      }
    }
  }

  const questions = toArray(xml.ehon.questions?.question);
  for (let qi = 0; qi < questions.length; qi++) {
    const q = questions[qi];
    const qPrefix = `question${qi + 1}`;
    for (const lang of ['ja', 'en'] as const) {
      const file = path.join(audiosDir, `${qPrefix}_${lang}.mp3`);
      console.log(`  ${qPrefix}_${lang}: "${q.text[lang]}"`);
      const audio = await synthesize(q.text[lang], lang);
      fs.writeFileSync(file, audio);
    }

    const choices = toArray(q.choices.choice);
    for (let ci = 0; ci < choices.length; ci++) {
      const cPrefix = `${qPrefix}_choice${ci + 1}`;
      for (const lang of ['ja', 'en'] as const) {
        const text = choices[ci][lang];
        const file = path.join(audiosDir, `${cPrefix}_${lang}.mp3`);
        console.log(`  ${cPrefix}_${lang}: "${text}"`);
        const audio = await synthesize(text, lang);
        fs.writeFileSync(file, audio);
      }
    }
  }
}

async function main(): Promise<void> {
  const bookId = process.argv[2];

  const targets = bookId
    ? [bookId]
    : fs.readdirSync(BOOKS_DIR, { withFileTypes: true })
        .filter((e) => e.isDirectory())
        .map((e) => e.name);

  for (const id of targets) {
    console.log(`\n[${id}]`);
    await generateForBook(id);
  }

  console.log('\nDone.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
