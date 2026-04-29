import 'dotenv/config';
import * as tts from '@google-cloud/text-to-speech';
import { XMLParser } from 'fast-xml-parser';
import * as fs from 'fs';
import * as path from 'path';

interface TextNode { ja: string; en: string }
interface PageNode { text: TextNode | TextNode[] }
interface ChoiceNode { ja: string; en: string }
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

function toArray<T>(value: T | T[] | undefined): T[] {
  if (value === undefined) return [];
  return Array.isArray(value) ? value : [value];
}

export class AudioGenerator {
  private readonly client = new tts.TextToSpeechClient();
  private readonly parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: '@_' });

  private readonly voiceConfig: Record<string, { languageCode: string; name: string }> = {
    ja: { languageCode: 'ja-JP', name: 'ja-JP-Wavenet-B' },
    en: { languageCode: 'en-US', name: 'en-US-Wavenet-C' },
  };

  private async synthesize(text: string, lang: 'ja' | 'en'): Promise<Buffer> {
    const voice = this.voiceConfig[lang];
    const [response] = await this.client.synthesizeSpeech({
      input: { text },
      voice,
      audioConfig: { audioEncoding: 'MP3' },
    });
    if (!response.audioContent) throw new Error(`No audio content for: ${text}`);
    return Buffer.from(response.audioContent as Uint8Array);
  }

  async generateForBook(bookDir: string): Promise<void> {
    const xmlPath = path.join(bookDir, 'book.xml');
    if (!fs.existsSync(xmlPath)) throw new Error(`book.xml not found: ${xmlPath}`);

    const audiosDir = path.join(bookDir, 'audios');
    if (!fs.existsSync(audiosDir)) fs.mkdirSync(audiosDir, { recursive: true });

    const xml = this.parser.parse(fs.readFileSync(xmlPath, 'utf-8')) as EhonXml;

    const pages = toArray(xml.ehon.page);
    for (let pi = 0; pi < pages.length; pi++) {
      const texts = toArray(pages[pi].text);
      for (let ti = 0; ti < texts.length; ti++) {
        const prefix = `page${pi + 1}_text${ti + 1}`;
        for (const lang of ['ja', 'en'] as const) {
          const file = path.join(audiosDir, `${prefix}_${lang}.mp3`);
          console.log(`  ${prefix}_${lang}: "${texts[ti][lang]}"`);
          fs.writeFileSync(file, await this.synthesize(texts[ti][lang], lang));
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
        fs.writeFileSync(file, await this.synthesize(q.text[lang], lang));
      }
      const choices = toArray(q.choices.choice);
      for (let ci = 0; ci < choices.length; ci++) {
        const cPrefix = `${qPrefix}_choice${ci + 1}`;
        for (const lang of ['ja', 'en'] as const) {
          const file = path.join(audiosDir, `${cPrefix}_${lang}.mp3`);
          console.log(`  ${cPrefix}_${lang}: "${choices[ci][lang]}"`);
          fs.writeFileSync(file, await this.synthesize(choices[ci][lang], lang));
        }
      }
    }
  }
}
