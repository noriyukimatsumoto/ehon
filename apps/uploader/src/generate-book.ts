import "dotenv/config";
import * as fs from "fs";
import * as path from "path";
import { GeminiClient } from "./gemini-client";
import { ImagenClient } from "./imagen-client";
import { BookParser, BookData, SceneData, ImagePrompts } from "./book-parser";
import { AudioGenerator } from "./audio-generator";
import { Part } from "@google/genai";

const BOOKS_DIR = path.resolve(
  process.env.BOOKS_DIR ?? path.join(__dirname, "..", "books"),
);

class BookGenerator {
  private readonly gemini = new GeminiClient();
  private readonly imagen = new ImagenClient();
  private readonly parser = new BookParser();
  private readonly audio = new AudioGenerator();

  async generate(title: string, bookId: string): Promise<void> {
    const bookDir = path.join(BOOKS_DIR, bookId);
    fs.mkdirSync(path.join(bookDir, "images"), { recursive: true });
    fs.mkdirSync(path.join(bookDir, "audios"), { recursive: true });

    // console.log("\n[1/6] title → story.txt");
    // await this.step1_summarize(title, bookDir);
    // console.log("  Done.");

    // console.log("\n[2/6] story.txt → story_reviewed.txt");
    // await this.step2_reviewStory(bookDir);
    // console.log("  Done.");

    // console.log("\n[3/6] story_reviewed.txt → scenes.json");
    // await this.step3_splitScenes(bookDir);
    // console.log("  Done.");

    console.log("\n[4/6] scenes.json → book.json");
    await this.step4_generateJson(bookDir);
    console.log("  Done.");

    console.log("\n[5/7] book.json → book.xml");
    this.step5_convertToXml(bookDir);
    console.log("  Done.");

    // console.log("\n[6/7] scenes.json → image_prompts.json");
    // await this.step6_generateImagePrompts(title, bookDir);
    // console.log("  Done.");

    // console.log("\n[8/8] image_prompts.json → images/scene*.jpg");
    // await this.step8_generateScenes(bookDir);
    // console.log("  Done.");

    // console.log("\n[8/8] book.xml → audios/");
    // await this.audio.generateForBook(bookDir);
    // console.log("  Done.");

    // this.writeMeta(title, bookId, bookDir);
    // console.log(`\n✓ Generated: ${bookDir}`);
    // console.log("  Next: Add to catalog.json, then run npm run upload");
  }

  // Step 1: タイトル → story.txt
  private async step1_summarize(title: string, bookDir: string): Promise<void> {
    const story = await this.gemini.summarizeByTitle(title);
    fs.writeFileSync(path.join(bookDir, "story.txt"), story, "utf-8");
  }

  // Step 2: story.txt → story_reviewed.txt
  private async step2_reviewStory(bookDir: string): Promise<void> {
    const story = fs.readFileSync(path.join(bookDir, "story.txt"), "utf-8");
    const reviewed = await this.gemini.reviewStory(story);
    fs.writeFileSync(
      path.join(bookDir, "story_reviewed.txt"),
      reviewed,
      "utf-8",
    );
  }

  // Step 3: story_reviewed.txt → scenes.json
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

  // Step 4: scenes.json → book.json
  private async step4_generateJson(bookDir: string): Promise<void> {
    const scenes = JSON.parse(
      fs.readFileSync(path.join(bookDir, "scenes.json"), "utf-8"),
    ) as SceneData[];
    const bookData = await this.gemini.generateBookJson(scenes);
    fs.writeFileSync(
      path.join(bookDir, "book.json"),
      JSON.stringify(bookData, null, 2),
      "utf-8",
    );
  }

  // Step 5: book.json → book.xml
  private step5_convertToXml(bookDir: string): void {
    const bookData = JSON.parse(
      fs.readFileSync(path.join(bookDir, "book.json"), "utf-8"),
    ) as BookData;
    const xml = this.parser.toXml(bookData);
    fs.writeFileSync(path.join(bookDir, "book.xml"), xml, "utf-8");
  }

  // Step 6: scenes.json → image_prompts.json
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

  // Step 8: image_prompts.json → images/scene*.jpg and cover.jpg
  private async step8_generateScenes(bookDir: string): Promise<void> {
    const prompts = JSON.parse(
      fs.readFileSync(path.join(bookDir, "image_prompts.json"), "utf-8"),
    ) as ImagePrompts;

    const coverPart = await this.imagen.generateImage(
      prompts.cover,
      path.join(bookDir, "cover.jpg"),
    );
    const parts: Part[] = [];

    for (const { filename, prompt } of prompts.scenes) {
      console.log(`  ${filename}: ${prompt.slice(0, 60)}`);
      const outputPath = path.join(bookDir, "images", filename);
      // 表紙 + シーンを会話履歴として渡す
      const refs: Part[] = [...coverPart, ...parts];
      console.log(
        `    refs: ${refs.length} parts (cover + ${parts.length} previous scenes)`,
      );
      const sceneParts = await this.imagen.generateImage(
        prompt,
        outputPath,
        refs,
      );
      parts.push(...sceneParts);
    }
  }
}

async function main(): Promise<void> {
  const title = process.argv[2];
  const bookId = process.argv[3];

  if (!title || !bookId) {
    console.error("Usage: ts-node src/generate-book.ts <title> <bookId>");
    console.error(
      'Example: ts-node src/generate-book.ts "カエルの王様" kaeru-no-osama',
    );
    process.exit(1);
  }

  await new BookGenerator().generate(title, bookId);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
