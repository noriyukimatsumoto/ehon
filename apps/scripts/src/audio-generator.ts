import "dotenv/config";
import { GoogleGenAI } from "@google/genai";
import * as fs from "fs";
import * as path from "path";
import type { AudioPromptEntry, AudioPromptsData } from "./book-parser";

const TTS_MODEL = "gemini-3.1-flash-tts-preview";

function pcmToWav(
  pcm: Buffer,
  sampleRate = 24000,
  channels = 1,
  bitDepth = 16,
): Buffer {
  const byteRate = sampleRate * channels * (bitDepth / 8);
  const blockAlign = channels * (bitDepth / 8);
  const header = Buffer.allocUnsafe(44);
  header.write("RIFF", 0);
  header.writeUInt32LE(36 + pcm.length, 4);
  header.write("WAVE", 8);
  header.write("fmt ", 12);
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(channels, 22);
  header.writeUInt32LE(sampleRate, 24);
  header.writeUInt32LE(byteRate, 28);
  header.writeUInt16LE(blockAlign, 32);
  header.writeUInt16LE(bitDepth, 34);
  header.write("data", 36);
  header.writeUInt32LE(pcm.length, 40);
  return Buffer.concat([header, pcm]);
}

export class AudioGenerator {
  private readonly genAI: GoogleGenAI;

  constructor() {
    const apiKey =
      process.env.GEMINI_API_KEY ??
      (() => {
        throw new Error("GEMINI_API_KEY is required");
      })();
    this.genAI = new GoogleGenAI({ apiKey });
  }

  private async synthesize(
    entry: AudioPromptEntry,
    voiceName: string,
    retries = 5,
  ): Promise<Buffer> {
    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const response = await this.genAI.models.generateContent({
          model: TTS_MODEL,
          contents: [
            { parts: [{ text: `${entry.prompt ?? ""}${entry.text}` }] },
          ],
          config: {
            responseModalities: ["AUDIO"],
            speechConfig: {
              voiceConfig: {
                prebuiltVoiceConfig: { voiceName },
              },
            },
          },
        });

        const data =
          response.candidates?.[0]?.content?.parts?.[0]?.inlineData?.data;
        if (!data) {
          console.error("No audio data in response:", response);
          throw new Error(`No audio data for: ${entry.audio}`);
        }

        return pcmToWav(Buffer.from(data, "base64"));
      } catch (err: unknown) {
        const isQuotaError =
          err instanceof Error && err.message.includes("429");
        if (!isQuotaError || attempt === retries) throw err;
        const waitSec = Math.pow(2, attempt + 1) * 15;
        console.error(
          `  Rate limited. Waiting ${waitSec}s before retry ${attempt + 1}/${retries}...`,
          err.message,
        );
        await new Promise((r) => setTimeout(r, waitSec * 1000));
      }
    }
    throw new Error("unreachable");
  }

  async generateForBook(
    bookDir: string,
    voiceName = "Achernar",
  ): Promise<void> {
    const promptsPath = path.join(bookDir, "audio_prompts.json");
    if (!fs.existsSync(promptsPath)) {
      throw new Error(`audio_prompts.json not found: ${promptsPath}`);
    }

    const { entries } = JSON.parse(
      fs.readFileSync(promptsPath, "utf-8"),
    ) as AudioPromptsData;

    const audiosDir = path.join(bookDir, "audios");
    fs.mkdirSync(audiosDir, { recursive: true });

    for (const entry of entries) {
      const file = path.join(audiosDir, `${entry.audio}.wav`);

      if (fs.existsSync(file)) {
        console.log(`  ${entry.audio}: skip (already exists)`);
        continue;
      }
      console.log(
        `  ${entry.audio}: "${entry.text.slice(0, 30)}" — ${entry.prompt}`,
      );
      fs.writeFileSync(file, await this.synthesize(entry, voiceName));
    }
  }
}
