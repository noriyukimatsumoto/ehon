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

  async generateStory(
    bookId: string,
    title: string,
    hint: string,
  ): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(bookDir, { recursive: true });

    console.log("\n[1/4] title → story.txt");
    const storyPath = await this.summarize(title, hint, bookDir);
    console.log("  Done.");

    console.log("\n[2/4] story.txt → story_reviewed.txt");
    const reviewedPath = await this.reviewStory(storyPath);
    console.log("  Done.");

    console.log("\n[3/4] story_reviewed.txt → scenes.json");
    const scenesPath = await this.splitScenes(reviewedPath);
    console.log("  Done.");

    console.log("\n[4/4] scenes.json → book.json");
    await this.buildBookJson(scenesPath, title);
    console.log("  Done.");
  }

  async generateImages(bookId: string, imageStyle: string): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(path.join(bookDir, "images"), { recursive: true });

    const bookPath = path.join(bookDir, "book.json");
    const { title } = JSON.parse(
      fs.readFileSync(bookPath, "utf-8"),
    ) as BookData;

    console.log("\n[1/2] scenes.json → image_prompts.json");
    const scenesPath = path.join(bookDir, "scenes.json");
    const promptsPath = await this.buildImagePrompts(
      scenesPath,
      title,
      imageStyle,
    );
    console.log("  Done.");

    console.log("\n[2/2] image_prompts.json → cover.jpg + images/scene*.jpg");
    await this.renderImages(promptsPath);
    console.log("  Done.");
  }

  async generateAudio(bookId: string): Promise<void> {
    const bookDir = this.bookDir(bookId);
    fs.mkdirSync(path.join(bookDir, "audios"), { recursive: true });

    console.log("\n[1/2] book.json → audio_prompts.json");
    const bookPath = path.join(bookDir, "book.json");
    await this.buildAudioPrompts(bookPath);
    console.log("  Done.");

    console.log("\n[2/2] audio_prompts.json → audios/");
    await this.audio.generateForBook(bookDir);
    console.log("  Done.");
  }

  private bookDir(bookId: string): string {
    return path.join(BOOKS_DIR, bookId);
  }

  private async summarize(
    title: string,
    hint: string,
    outputDir: string,
  ): Promise<string> {
    const story = await this.gemini.summarizeByTitle(title, hint);
    const outputPath = path.join(outputDir, "story.txt");
    fs.writeFileSync(outputPath, story, "utf-8");
    return outputPath;
  }

  private async reviewStory(storyPath: string): Promise<string> {
    const story = fs.readFileSync(storyPath, "utf-8");
    const reviewed = await this.gemini.reviewStory(story);
    const outputPath = path.join(path.dirname(storyPath), "story_reviewed.txt");
    fs.writeFileSync(outputPath, reviewed, "utf-8");
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
}
