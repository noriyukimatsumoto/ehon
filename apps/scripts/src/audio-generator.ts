import "dotenv/config";
import * as tts from "@google-cloud/text-to-speech";
import * as fs from "fs";
import * as path from "path";
import type { AudioPromptEntry, AudioPromptsData } from "./book-parser";

export class AudioGenerator {
  private readonly client = new tts.TextToSpeechClient();

  private readonly voiceConfig: Record<
    string,
    { languageCode: string; name: string }
  > = {
    ja: { languageCode: "ja-JP", name: "ja-JP-Wavenet-B" },
    en: { languageCode: "en-US", name: "en-US-Wavenet-C" },
  };

  private async synthesize(entry: AudioPromptEntry): Promise<Buffer> {
    const voice = this.voiceConfig[entry.lang];
    const [response] = await this.client.synthesizeSpeech({
      input: { text: entry.text },
      voice,
      audioConfig: { audioEncoding: "MP3" },
    });
    if (!response.audioContent) {
      throw new Error(`No audio content for: ${entry.audio}`);
    }
    return Buffer.from(response.audioContent as Uint8Array);
  }

  async generateForBook(bookDir: string): Promise<void> {
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
      const file = path.join(audiosDir, `${entry.audio}.mp3`);
      console.log(
        `  ${entry.audio}: "${entry.text.slice(0, 30)}" — ${entry.prompt}`,
      );
      fs.writeFileSync(file, await this.synthesize(entry));
    }
  }
}
