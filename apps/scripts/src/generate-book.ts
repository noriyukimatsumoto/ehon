import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { GeminiClient } from "./gemini-client";
import { ImagenClient } from "./imagen-client";
import {
  BookData,
  SceneData,
  ImagePrompts,
  AudioPromptsData,
} from "./book-parser";
import { AudioGenerator } from "./audio-generator";
import { Part } from "@google/genai";

const BOOKS_DIR = path.resolve(
  process.env.BOOKS_DIR ?? path.join(__dirname, "..", "books"),
);

export class BookGenerator {
  private readonly gemini = new GeminiClient();
  private readonly imagen = new ImagenClient();
  private readonly audio = new AudioGenerator();

  // step1~4: title → story.txt → story_reviewed.txt → scenes.json → book.json
  async generateStory(
    bookId: string,
    title: string,
    hint: string,
  ): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(bookDir, { recursive: true });

    console.log("\n[1/4] title → story.txt");
    await this.step1_summarize(title, bookDir, hint);
    console.log("  Done.");

    console.log("\n[2/4] story.txt → story_reviewed.txt");
    await this.step2_reviewStory(bookDir);
    console.log("  Done.");

    console.log("\n[3/4] story_reviewed.txt → scenes.json");
    await this.step3_splitScenes(bookDir);
    console.log("  Done.");

    console.log("\n[4/4] scenes.json → book.json");
    await this.step4_generateJson(bookDir, title);
    console.log("  Done.");
  }

  // step6~7: scenes.json → image_prompts.json → cover.jpg + images/scene*.jpg
  async generateImages(bookId: string): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(path.join(bookDir, "images"), { recursive: true });

    const { title } = JSON.parse(
      fs.readFileSync(path.join(bookDir, "book.json"), "utf-8"),
    ) as BookData;

    console.log("\n[1/2] scenes.json → image_prompts.json");
    await this.step6_generateImagePrompts(title, bookDir);
    console.log("  Done.");

    console.log("\n[2/2] image_prompts.json → cover.jpg + images/scene*.jpg");
    await this.step7_generateImages(bookDir);
    console.log("  Done.");
  }

  // step8a+8b: book.json → audio_prompts.json → audios/
  async generateAudio(bookId: string): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(path.join(bookDir, "audios"), { recursive: true });

    console.log("\n[1/2] book.json → audio_prompts.json");
    await this.step8a_generateAudioPrompts(bookDir);
    console.log("  Done.");

    console.log("\n[2/2] audio_prompts.json → audios/");
    await this.audio.generateForBook(bookDir);
    console.log("  Done.");
  }

  private async step8a_generateAudioPrompts(bookDir: string): Promise<void> {
    const bookData = JSON.parse(
      fs.readFileSync(path.join(bookDir, "book.json"), "utf-8"),
    ) as BookData;
    const audioPrompts: AudioPromptsData =
      await this.gemini.generateAudioPrompts(bookData);
    fs.writeFileSync(
      path.join(bookDir, "audio_prompts.json"),
      JSON.stringify(audioPrompts, null, 2),
      "utf-8",
    );
  }

  private bookDir(bookId: string): string {
    return path.join(BOOKS_DIR, bookId);
  }

  private async step1_summarize(
    title: string,
    bookDir: string,
    hint: string,
  ): Promise<void> {
    const story = await this.gemini.summarizeByTitle(title, hint);
    fs.writeFileSync(path.join(bookDir, "story.txt"), story, "utf-8");
  }

  private async step2_reviewStory(bookDir: string): Promise<void> {
    const story = fs.readFileSync(path.join(bookDir, "story.txt"), "utf-8");
    const reviewed = await this.gemini.reviewStory(story);
    fs.writeFileSync(
      path.join(bookDir, "story_reviewed.txt"),
      reviewed,
      "utf-8",
    );
  }

  private async step3_splitScenes(bookDir: string): Promise<void> {
    const story = fs.readFileSync(
      path.join(bookDir, "story_reviewed.txt"),
      "utf-8",
    );
    const scenes = await this.gemini.splitIntoScenes(story);
    fs.writeFileSync(
      path.join(bookDir, "scenes.json"),
      JSON.stringify(scenes, null, 2),
      "utf-8",
    );
  }

  private async step4_generateJson(
    bookDir: string,
    title: string,
  ): Promise<void> {
    const scenes = JSON.parse(
      fs.readFileSync(path.join(bookDir, "scenes.json"), "utf-8"),
    ) as SceneData[];
    const bookData = await this.gemini.generateBookJson(scenes);
    bookData.title = title;
    fs.writeFileSync(
      path.join(bookDir, "book.json"),
      JSON.stringify(bookData, null, 2),
      "utf-8",
    );
  }

  private async step6_generateImagePrompts(
    title: string,
    bookDir: string,
  ): Promise<void> {
    const scenes = JSON.parse(
      fs.readFileSync(path.join(bookDir, "scenes.json"), "utf-8"),
    ) as SceneData[];
    const prompts: ImagePrompts = await this.gemini.generateImagePrompts(
      title,
      scenes,
    );
    fs.writeFileSync(
      path.join(bookDir, "image_prompts.json"),
      JSON.stringify(prompts, null, 2),
      "utf-8",
    );
  }

  private async step7_generateImages(bookDir: string): Promise<void> {
    const prompts = JSON.parse(
      fs.readFileSync(path.join(bookDir, "image_prompts.json"), "utf-8"),
    ) as ImagePrompts;

    console.log("  cover.jpg");
    const coverParts = await this.imagen.generateImage(
      prompts.cover,
      path.join(bookDir, "cover.jpg"),
    );

    const history: Part[] = [];
    for (const { filename, prompt } of prompts.scenes) {
      console.log(`  ${filename}: ${prompt.slice(0, 60)}`);
      const outputPath = path.join(bookDir, "images", filename);
      const refs: Part[] = [...coverParts, ...history];
      const sceneParts = await this.imagen.generateImage(
        prompt,
        outputPath,
        refs,
      );
      history.push(...sceneParts);
    }
  }
}
