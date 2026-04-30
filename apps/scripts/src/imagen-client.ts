import "dotenv/config";
import {
  ContentListUnion,
  GoogleGenAI,
  PartUnion,
  type Part,
} from "@google/genai";
import * as fs from "fs";

const IMAGEN_MODEL = "gemini-3.1-flash-image-preview";

export class ImagenClient {
  private readonly genAI: GoogleGenAI;

  constructor() {
    const apiKey =
      process.env.GEMINI_API_KEY ??
      (() => {
        throw new Error("GEMINI_API_KEY is required");
      })();
    this.genAI = new GoogleGenAI({ apiKey });
  }

  // 生成した画像の modelParts を返す（次ターンの会話履歴に使う）
  async generateImage(
    prompt: string,
    outputPath: string,
    references: Part[] = [],
    retries = 5,
  ): Promise<Part[]> {
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const contents = await this.buildContents(prompt, references);

        const response = await this.genAI.models.generateContent({
          model: IMAGEN_MODEL,
          contents,
          config: {
            systemInstruction: `あなたはプロのイラストレーターです。以下のプロンプトをもとに、子ども向け絵本のイラストを生成してください。
【ルール】
  - イラスト内には文字・セリフを入れないでください。
  - プロンプト内の登場人物以外が写り込まないようにしてください。
  - 登場人物はそれぞれ違う特徴で描いてください。
            `,
            responseModalities: ["IMAGE"],
            imageConfig: {
              aspectRatio: "16:9",
              imageSize: "1k",
            },
          },
        });

        const modelParts = response.candidates?.[0]?.content?.parts ?? [];
        const imagePart = modelParts.find((p) =>
          p.inlineData?.mimeType?.startsWith("image/"),
        );
        const imageBytes = imagePart?.inlineData?.data;
        if (!imageBytes) {
          console.error("No image data in response:", response);
          throw new Error("generateContent returned no image");
        }
        fs.writeFileSync(outputPath, Buffer.from(imageBytes, "base64"));
        return modelParts;
      } catch (err: unknown) {
        console.error(`  Error (attempt ${attempt + 1}/${retries + 1}):`, err);
        const isQuotaError =
          err instanceof Error && err.message.includes("429");
        if (!isQuotaError || attempt === retries) throw err;
        const waitSec = Math.pow(2, attempt + 1) * 15;
        console.log(
          `  Rate limited. Waiting ${waitSec}s before retry ${attempt + 1}/${retries}...`,
        );
        await new Promise((r) => setTimeout(r, waitSec * 1000));
      }
    }
    return [];
  }

  private async buildContents(
    prompt: string,
    parts: Part[],
  ): Promise<PartUnion[]> {
    if (parts.length === 0) return [prompt];

    const turns: PartUnion[] = [];
    turns.push(...parts);
    turns.push(prompt);
    return turns;
  }
}
