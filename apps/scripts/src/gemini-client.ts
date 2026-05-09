import "dotenv/config";
import { GoogleGenAI, Type } from "@google/genai";
import type {
  BookData,
  SceneData,
  ImagePrompts,
  AudioPromptsData,
  MetaData,
} from "./book-parser";

const META_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    title: {
      type: Type.OBJECT,
      properties: {
        en: { type: Type.STRING },
      },
      required: ["en"],
    },
    categoryId: { type: Type.STRING },
    categoryName: {
      type: Type.OBJECT,
      properties: {
        ja: { type: Type.STRING },
        en: { type: Type.STRING },
      },
      required: ["ja", "en"],
    },
  },
  required: ["title", "categoryId", "categoryName"],
};

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
        },
        required: ["audio", "lang", "text"],
      },
    },
  },
  required: ["entries"],
};

const IMAGE_PROMPTS_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    characters: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          name: { type: Type.STRING },
          characteristics: { type: Type.STRING },
        },
        required: ["name", "characteristics"],
      },
    },
    cover: { type: Type.STRING },
    scenes: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          scene: { type: Type.INTEGER },
          filename: { type: Type.STRING },
          prompt: { type: Type.STRING },
          names: {
            type: Type.ARRAY,
            items: { type: Type.STRING },
          },
        },
        required: ["scene", "filename", "prompt", "names"],
      },
    },
  },
  required: ["cover", "scenes", "characters"],
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

  async summarize(
    description: string,
    systemInstruction?: string,
  ): Promise<string> {
    const baseInstruction =
      "物語の登場人物・出来事・結末を指示通りに要約してください。";
    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: description,
      config: {
        systemInstruction: systemInstruction
          ? `${baseInstruction}\n\n${systemInstruction}`
          : baseInstruction,
      },
    });
    return result.text ?? "";
  }

  async splitIntoScenes(story: string): Promise<SceneData[]> {
    const prompt = `以下の物語を、背景や状況が変わるタイミングでシーンに分割してください。
シーンは最大10個までです。
各シーンには scene（連番）と、そのシーンの物語文（text）を含めてください。
物語の全ての文章を含めてください。
各シーンの物語文は、同量となるように調整してください。

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
- pages はシーンの数と同じにしてください（scene{N}.png は各シーンに対応）
- 各ページの text は、シーン内の文章を区切るために使用されます。適切な位置で文章を区切り、ja は25文字程度の日本語、en は英語訳にしてください。シーン内の全ての文章を含めるようにtextを作成してください。
- image の値は scene{N}.png（N = 1〜、シーン番号に対応）
- questions は3~5問作成する
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
    imageStyle: string,
  ): Promise<ImagePrompts> {
    const scenesText = scenes
      .map((s) => `【シーン${s.scene}】\n${s.text}`)
      .join("\n\n");

    const prompt = `以下のシーン構成をもとに、画像生成AIへ渡すための日本語プロンプトを作成してください。
次に表紙（cover）と各シーン（scenes）それぞれにプロンプトを作成してください。

プロンプトで指定する、画像のスタイルは以下のようにしてください。



- characters: 物語に登場する全ての人物や動物の外見的特徴を具体的に描写してください。nameには登場人物や動物の名前を使用してください。シーンによって同じ人物であるが、外見的特徴が変化する場合は、別の名前をつけてください。(例：「男」「男(成長後)」)
- cover：物語「${title}」の表紙にふさわしいプロンプト。文字の記載がない。登場人物や背景の特徴を具体的に描写してください。
- scenes：各シーンの内容を的確に表現する日本語プロンプト。filename は scene{N}.png（Nはシーン番号）。
  - 以下の順でプロンプトを構成してください。
    1. 主題: 画像の主体となる物体、人物、動物、風景などです。
    2. コンテキストと背景: たとえば、スタジオの白い背景、屋外、屋内の環境などです。
    3. 登場人物: シーンに登場する人物や動物がいる場合は、それらをプロンプトに含めてください。登場人物の特徴や表情、ポーズなども具体的に描写してください。
  - 例 scene1.png のプロンプト：「男の子が大きな心を抱えている様子。夜空の下、星が輝いている。男の子は笑顔で、周りには小さな動物たちが集まっている。全体的に温かみのある色合い。」
- scenes の names: シーン内に登場する、登場人物や動物の名前をリスト形式で記載してください。characters と同じ名前を使用してください。

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

  async generateMeta(
    bookId: string,
    titleJa: string,
    story: string,
  ): Promise<MetaData> {
    const prompt = `以下の絵本のメタ情報を生成してください。

【絵本ID】${bookId}
【タイトル（日本語）】${titleJa}
【物語】
${story}

以下を生成してください：
- title.en: タイトルの英訳
- categoryId: カテゴリID（英数字小文字、ハイフン使用可。例: "grimm", "andersen", "aesop", "japanese-folktale"）
- categoryName.ja: カテゴリ名（日本語）
- categoryName.en: カテゴリ名（英語）`;

    const result = await this.genAI.models.generateContent({
      model: this.model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: META_SCHEMA,
      },
    });

    const generated = JSON.parse(result.text ?? "{}") as {
      title: { en: string };
      categoryId: string;
      categoryName: { ja: string; en: string };
    };

    return {
      id: bookId,
      version: "1.0.0",
      title: { ja: titleJa, en: generated.title.en },
      categoryId: generated.categoryId,
      categoryName: generated.categoryName,
    };
  }

  async generateAudioPrompts(bookData: BookData): Promise<AudioPromptsData> {
    const prompt = `以下のデータをもとに、各テキストの音声読み上げ設定を生成してください。

【データ】
${JSON.stringify(bookData, null, 2)}

ルール：
- pages の texts（ja/en）は、全てのテキストを読み上げる必要があります。テキストを省略せず、全てentriesに含めてください。
- questions は、質問文と全ての選択肢を結合した1エントリのみ作成してください（ja・enそれぞれ）。
  - choices の各エントリは個別にentriesへ含めないでください。
  - audio は question の audio フィールドに "_ja" または "_en" を付けた値（例: "question1_ja"）
  - 日本語は選択肢を「、」で区切り、英語は「, 」で区切って結合してください。
- audio は book.json の audio フィールドに "_ja" または "_en" を付けた値（例: "page1_text1_ja"）
- lang は "ja" または "en"
- text は実際に読み上げるテキスト。データを変更しないこと。物語の文脈に合ったブランケットタグを英語で追加すること。
  - ブランケットタグは、"[tag1, tag2]" のように複数指定可能。タグの例は以下の通りです。
    - [happy], [sad], [angry], [calm], [excited], [scared], [narration], [questioning] など、テキストの感情やスタイルを表すタグ
    - [soft], [loud], [whisper], [shout] など、音量や話し方を表すタグ
  - ブランケットタグは、必ずテキストの前に含めてください。
  - 台詞と地の文が混在する箇所は、ブランケットタグを使用して区別してください。例えば、台詞には [happy]、地の文には [narration] を使用するなどしてください。
  - questions には必ず [questioning] タグを使用してください。

【pages の例】
book.json の page1 の texts に { ja: "ある日、桃太郎はおじいさんとおばあさんに言いました。「僕、鬼ヶ島に行って、悪い鬼たちを退治してきたいんです。」", en: "One day, Momotaro told his grandparents, 'I want to go to Onigashima and defeat the wicked ogres.'" } があれば、entriesには以下の2つを含める必要があります。
  {
    "audio": "page1_text1_ja",
    "lang": "ja",
    "text": "[narration,soft]ある日、桃太郎はおじいさんとおばあさんに言いました。[determined]「僕、鬼ヶ島に行って、悪い鬼たちを退治してきたいんです。」"
  },
  {
    "audio": "page1_text1_en",
    "lang": "en",
    "text": "[narration,soft]One day, Momotaro told his grandparents, [determined]'I want to go to Onigashima and defeat the wicked ogres.'"
  }

【questions の例】
question1 の ja が "桃太郎はどこから生まれましたか？" で choices が ["木", "桃", "岩"] であれば、entriesには以下の2つを含める必要があります（choicesの個別エントリは不要）。
  {
    "audio": "question1_ja",
    "lang": "ja",
    "text": "[questioning]桃太郎はどこから生まれましたか？木、桃、岩"
  },
  {
    "audio": "question1_en",
    "lang": "en",
    "text": "[questioning]Where was Momotaro born? A tree, A peach, A rock"
  }

`;

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
