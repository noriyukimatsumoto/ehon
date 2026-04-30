import "dotenv/config";
import { GoogleGenAI, Type } from "@google/genai";
import type {
  BookData,
  SceneData,
  ImagePrompts,
  AudioPromptsData,
} from "./book-parser";

const AUDIO_PROMPTS_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    entries: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          audio: { type: Type.STRING },
          lang: { type: Type.STRING },
          text: { type: Type.STRING },
          prompt: { type: Type.STRING },
        },
        required: ["audio", "lang", "text", "prompt"],
      },
    },
  },
  required: ["entries"],
};

const IMAGE_PROMPTS_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    cover: { type: Type.STRING },
    scenes: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          scene: { type: Type.INTEGER },
          filename: { type: Type.STRING },
          prompt: { type: Type.STRING },
        },
        required: ["scene", "filename", "prompt"],
      },
    },
  },
  required: ["cover", "scenes"],
};

const SCENE_JSON_SCHEMA = {
  type: Type.ARRAY,
  items: {
    type: Type.OBJECT,
    properties: {
      scene: { type: Type.INTEGER },
      text: { type: Type.STRING },
    },
    required: ["scene", "text"],
  },
};

const BOOK_JSON_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    pages: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          texts: {
            type: Type.ARRAY,
            items: {
              type: Type.OBJECT,
              properties: {
                ja: { type: Type.STRING },
                en: { type: Type.STRING },
                duration: { type: Type.NUMBER },
                audio: { type: Type.STRING },
              },
              required: ["ja", "en", "duration", "audio"],
            },
          },
          image: { type: Type.STRING },
        },
        required: ["texts", "image"],
      },
    },
    questions: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          ja: { type: Type.STRING },
          en: { type: Type.STRING },
          duration: { type: Type.NUMBER },
          answerDuration: { type: Type.NUMBER },
          audio: { type: Type.STRING },
          image: { type: Type.STRING },
          choices: {
            type: Type.ARRAY,
            items: {
              type: Type.OBJECT,
              properties: {
                ja: { type: Type.STRING },
                en: { type: Type.STRING },
                correct: { type: Type.BOOLEAN },
                audio: { type: Type.STRING },
              },
              required: ["ja", "en", "correct", "audio"],
            },
          },
        },
        required: [
          "ja",
          "en",
          "duration",
          "answerDuration",
          "audio",
          "image",
          "choices",
        ],
      },
    },
  },
  required: ["pages", "questions"],
};

export class GeminiClient {
  private readonly genAI: GoogleGenAI;
  private readonly model: string;

  constructor() {
    const project =
      process.env.GCP_PROJECT ??
      (() => {
        throw new Error("GCP_PROJECT is required");
      })();
    const location = process.env.GCP_LOCATION ?? "us-central1";
    this.model = process.env.GEMINI_MODEL ?? "gemini-2.5-flash-lite";
    this.genAI = new GoogleGenAI({ vertexai: true, project, location });
  }

  async reviewStory(story: string): Promise<string> {
    const prompt = `以下の物語文を一文ずつ丁寧に校正してください。

【校正観点】
1. 意味が通っているか（最重要）
   - 文節・フレーズの意味が日本語として成立しているか
   - 意味が曖昧・不明瞭・矛盾している箇所は文脈から推測して自然な表現に直す
   - 例：「こころがおおきくだけだったので」→「こころがいっぱいだったので」
   - 例：「なくことがはじめました」→「なきはじめました」
2. 助詞・助動詞・動詞活用が正しいか
   - 「〜することがはじめました」「〜のことがしました」などのパターンは誤り
3. ひらがな・カタカナのみで書かれているか（漢字はひらがな・カタカナに直す）
4. 3〜6歳の子どもが理解できる言葉かどうか（むずかしい言葉は言い換える）
5. 声に出して読んだときにテンポよく聞こえるか

修正後の物語文のみを出力してください。

【物語文】
${story}`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
    });
    return result.text ?? story;
  }

  async summarizeByTitle(title: string, hint: string): Promise<string> {
    const prompt = `「${title}」を3〜6歳の子ども向けの絵本として語り直してください。

物語「${title}」の内容に関しては、以下を参考にしてください。

${hint}

ルール：
- ひらがなとカタカナを中心に書いてください。漢字は使わないでください。
- やさしい言葉づかいで、テンポよく読み聞かせられる文体にしてください。
- 登場人物・出来事・結末をすべて含め、500文字程度の物語文にしてください。
- 物語文のみを出力してください。`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
    });
    return result.text ?? "";
  }

  async splitIntoScenes(story: string): Promise<SceneData[]> {
    const prompt = `以下の物語を、背景や状況が変わるタイミングでシーンに分割してください。
シーンは最大10個までです。
各シーンには scene（連番）と、そのシーンの物語文（text）を含めてください。
物語の全ての文章を含めてください。

【物語】
${story}`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: SCENE_JSON_SCHEMA,
      },
    });

    return JSON.parse(result.text ?? "[]") as SceneData[];
  }

  async generateBookJson(scenes: SceneData[]): Promise<BookData> {
    const scenesText = scenes
      .map((s) => `【シーン${s.scene}】\n${s.text}`)
      .join("\n\n");

    const prompt = `以下のシーン構成の物語をもとに絵本のデータを生成してください。
各シーンが1ページに対応します。シーン内の全ての文章を含めるように作成してください。

ルール：
- pages はシーンの数と同じにしてください（scene{N}.jpg は各シーンに対応）
- 各ページの text は、シーン内の文章を区切るために使用されます。適切な位置で文章を区切り、ja は25文字程度の日本語、en は英語訳にしてください。シーン内の全ての文章を含めるようにtextを作成してください。
- image の値は scene{N}.jpg（N = 1〜、シーン番号に対応）
- questions は5問以上作成する
- 各 question の choices はちょうど3つ、correct:true は1つのみ
- audio の値は page{N}_text{M} / question{N} / question{N}_choice{M} の命名規則に従う

${scenesText}

`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: BOOK_JSON_SCHEMA,
      },
    });

    return JSON.parse(result.text ?? "{}") as BookData;
  }

  async generateImagePrompts(
    title: string,
    scenes: SceneData[],
  ): Promise<ImagePrompts> {
    const scenesText = scenes
      .map((s) => `【シーン${s.scene}】\n${s.text}`)
      .join("\n\n");

    const prompt = `以下のシーン構成をもとに、画像生成AIへ渡すための日本語プロンプトを作成してください。
次に表紙（cover）と各シーン（scenes）それぞれにプロンプトを作成してください。
- cover：物語「${title}」の表紙にふさわしいプロンプト。文字の記載がない、子ども向けのイラストを想定してください。登場人物や背景の特徴を具体的に描写してください。
- scenes：各シーンの内容を的確に表現する日本語プロンプト。filename は scene{N}.jpg（Nはシーン番号）。子ども向けのイラストを想定してください。
  - 以下の順でプロンプトを構成してください。
    1. 主題: プロンプトについて最初に考えるべきなのは主題、すなわち画像の主体となる物体、人物、動物、風景などです。
    2. コンテキストと背景: その主題が配置される背景やコンテキストも同様に重要です。主題をさまざまな背景に置いてみてください。たとえば、スタジオの白い背景、屋外、屋内の環境などです。
    3. スタイルとムード: 画像のスタイルやムードもプロンプトに含めるべき重要な要素です。たとえば、明るくカラフルなスタイル、暗くて陰鬱なムード、子ども向けのかわいらしいスタイルなどです。
    4. 登場人物: シーンに登場する人物や動物がいる場合は、それらをプロンプトに含めてください。登場人物の特徴や表情、ポーズなども具体的に描写してください。

  - 例 scene1.jpg のプロンプト：「男の子が大きな心を抱えている様子。夜空の下、星が輝いている。男の子は笑顔で、周りには小さな動物たちが集まっている。全体的に温かみのある色合いで、子ども向けのイラストスタイル。【登場人物】男の子・小さな動物たち」
${scenesText}`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: IMAGE_PROMPTS_SCHEMA,
      },
    });

    return JSON.parse(result.text ?? "{}") as ImagePrompts;
  }

  async generateAudioPrompts(bookData: BookData): Promise<AudioPromptsData> {
    const prompt = `以下の絵本データをもとに、各テキストの音声読み上げ設定を生成してください。

【絵本データ】
${JSON.stringify(bookData, null, 2)}

ルール：
- pages の texts（ja/en）、questions の本文（ja/en）、questions の choices（ja/en）をすべて entries に含める
- audio は book.json の audio フィールドに "_ja" または "_en" を付けた値（例: "page1_text1_ja"）
- lang は "ja" または "en"
- text は実際に読み上げるテキスト
- prompt は物語の文脈に合ったスタイルをブラケットタグ形式の英語で記述する
  - 形式: "[tag1, tag2]" のように複数指定可能
  - 使用できるタグ例: slowly, quickly, warmly, gently, excitedly, sadly, fearfully, cheerfully, whispering, dramatically, calmly, tenderly
  - 例: "[slowly, warmly]", "[excitedly, quickly]", "[sadly, gently]"`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: AUDIO_PROMPTS_SCHEMA,
      },
    });

    return JSON.parse(result.text ?? "{}") as AudioPromptsData;
  }
}
