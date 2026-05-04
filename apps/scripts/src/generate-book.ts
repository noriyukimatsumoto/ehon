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
  MetaData,
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

  async generateStory(
    bookId: string,
    description: string,
    systemInstruction?: string,
  ): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(bookDir, { recursive: true });

    console.log("\n[1/2] description → story.txt");
    await this.summarize(description, bookDir, systemInstruction);
    console.log("  Done.");
  }

  async generateScenes(
    bookId: string,
    title: string,
    imageStyle: string,
  ): Promise<void> {
    const bookDir = this.bookDir(bookId);
    const storyPath = path.join(bookDir, "story.txt");

    console.log("\n[1/5] story.txt → scenes.json");
    const scenesPath = await this.splitScenes(storyPath);
    console.log("  Done.");

    console.log("\n[2/5] scenes.json → book.json");
    const bookPath = await this.buildBookJson(scenesPath, title);
    console.log("  Done.");

    console.log("\n[3/5] scenes.json → image_prompts.json");
    await this.buildImagePrompts(scenesPath, title, imageStyle);
    console.log("  Done.");

    console.log("\n[4/5] book.json → audio_prompts.json");
    await this.buildAudioPrompts(bookPath);
    console.log("  Done.");

    console.log("\n[5/5] story.txt + title → meta.json");
    await this.buildMeta(bookId, title, bookDir);
    console.log("  Done.");
  }

  async generateImages(bookId: string): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(path.join(bookDir, "images"), { recursive: true });

    const promptsPath = path.join(bookDir, "image_prompts.json");

    console.log("\n[1/1] image_prompts.json → cover.png + images/scene*.png");
    await this.renderImages(promptsPath);
    console.log("  Done.");
  }

  async generateMetaFile(): Promise<void> {
    console.log("\n[1/1] meta.json × all books → books.json");
    this.updateCatalog();
    console.log("  Done.");
  }

  async generateAudio(bookId: string, voiceName?: string): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(path.join(bookDir, "audios"), { recursive: true });

    console.log("\n[1/1] audio_prompts.json → audios/");
    await this.audio.generateForBook(bookDir, voiceName);
    console.log("  Done.");
  }

  private bookDir(bookId: string): string {
    return path.join(BOOKS_DIR, bookId);
  }

  private async summarize(
    description: string,
    outputDir: string,
    systemInstruction?: string,
  ): Promise<string> {
    const story = await this.gemini.summarize(description, systemInstruction);
    const outputPath = path.join(outputDir, "story.txt");
    fs.writeFileSync(outputPath, story, "utf-8");
    return outputPath;
  }

  private async splitScenes(storyPath: string): Promise<string> {
    const story = fs.readFileSync(storyPath, "utf-8");
    const scenes = await this.gemini.splitIntoScenes(story);
    const outputPath = path.join(path.dirname(storyPath), "scenes.json");
    fs.writeFileSync(outputPath, JSON.stringify(scenes, null, 2), "utf-8");
    return outputPath;
  }

  private async buildBookJson(
    scenesPath: string,
    title: string,
  ): Promise<string> {
    const scenes = JSON.parse(
      fs.readFileSync(scenesPath, "utf-8"),
    ) as SceneData[];
    const bookData = await this.gemini.generateBookJson(scenes);
    bookData.title = title;
    const outputPath = path.join(path.dirname(scenesPath), "book.json");
    fs.writeFileSync(outputPath, JSON.stringify(bookData, null, 2), "utf-8");
    return outputPath;
  }

  private async buildImagePrompts(
    scenesPath: string,
    title: string,
    imageStyle: string,
  ): Promise<string> {
    const scenes = JSON.parse(
      fs.readFileSync(scenesPath, "utf-8"),
    ) as SceneData[];
    const prompts: ImagePrompts = await this.gemini.generateImagePrompts(
      title,
      scenes,
      imageStyle,
    );
    const outputPath = path.join(
      path.dirname(scenesPath),
      "image_prompts.json",
    );
    fs.writeFileSync(outputPath, JSON.stringify(prompts, null, 2), "utf-8");
    return outputPath;
  }

  private async renderImages(promptsPath: string): Promise<void> {
    const bookDir = path.dirname(promptsPath);
    const prompts = JSON.parse(
      fs.readFileSync(promptsPath, "utf-8"),
    ) as ImagePrompts;

    console.log("  cover.png");
    const coverParts = await this.imagen.generateImage(
      prompts.cover,
      path.join(bookDir, "cover.png"),
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

  private async buildAudioPrompts(bookPath: string): Promise<string> {
    const bookData = JSON.parse(fs.readFileSync(bookPath, "utf-8")) as BookData;
    const audioPrompts: AudioPromptsData =
      await this.gemini.generateAudioPrompts(bookData);
    const outputPath = path.join(path.dirname(bookPath), "audio_prompts.json");
    fs.writeFileSync(
      outputPath,
      JSON.stringify(audioPrompts, null, 2),
      "utf-8",
    );
    return outputPath;
  }

  private async buildMeta(
    bookId: string,
    title: string,
    bookDir: string,
  ): Promise<string> {
    const story = fs.readFileSync(path.join(bookDir, "story.txt"), "utf-8");
    const meta: MetaData = await this.gemini.generateMeta(bookId, title, story);
    const outputPath = path.join(bookDir, "meta.json");
    fs.writeFileSync(outputPath, JSON.stringify(meta, null, 2), "utf-8");
    return outputPath;
  }

  private updateCatalog(): void {
    const entries = fs
      .readdirSync(BOOKS_DIR, { withFileTypes: true })
      .filter((d) => d.isDirectory())
      .flatMap((d) => {
        const metaPath = path.join(BOOKS_DIR, d.name, "meta.json");
        if (!fs.existsSync(metaPath)) return [];
        return [JSON.parse(fs.readFileSync(metaPath, "utf-8")) as MetaData];
      });
    fs.writeFileSync(
      path.join(BOOKS_DIR, "books.json"),
      JSON.stringify(entries, null, 2),
      "utf-8",
    );
  }
}
