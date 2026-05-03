import "dotenv/config";
import * as fs from "fs";
import { parse as parseYaml } from "yaml";
import { BookGenerator } from "./generate-book";
import { upload } from "./uploader";

const [, , command, ...args] = process.argv;

function usage(): void {
  console.error(`
使い方: ts-node src/cli.ts <command> [options]

Commands:
  upload [inputFile]   ファイルをGCSにアップロードする（inputFile省略時は全冊）
  story  <inputFile>   物語テキストを生成する (step1~2: story.txt, story_reviewed.txt)
  scenes <inputFile>   シーン分割・JSONを生成する (step3~4: scenes.json, book.json)
  images <inputFile>   画像プロンプトと画像を生成する (step5~6)
  audio  <inputFile>   音声ファイルを生成する (step7)

inputFile (YML形式):
  id: kaeru-no-osama
  title: カエルの王様
  imageStyle: 水彩画タッチの子ども向けイラスト
  description:
    - グリム童話の「カエルの王様」
    - 魔法でカエルにされた王子の物語

例:
  ts-node src/cli.ts story  story.yml
  ts-node src/cli.ts scenes story.yml
  ts-node src/cli.ts images story.yml
  ts-node src/cli.ts audio  story.yml
  ts-node src/cli.ts upload story.yml
  ts-node src/cli.ts upload
`);
  process.exit(1);
}

function parseInputYml(filePath: string): {
  id: string;
  title: string;
  description: string;
  imageStyle: string;
} {
  const raw = parseYaml(fs.readFileSync(filePath, "utf-8")) as Record<
    string,
    unknown
  >;

  const id = raw.id as string;
  if (!id) throw new Error(`inputFile に id が見つかりません: ${filePath}`);
  const title = raw.title as string;
  if (!title)
    throw new Error(`inputFile に title が見つかりません: ${filePath}`);

  const toStr = (v: unknown): string => {
    if (!v) return "";
    if (typeof v === "string") return v.trim();
    if (Array.isArray(v)) return v.map((item) => `- ${item}`).join("\n");
    return String(v);
  };

  return {
    id,
    title,
    description: toStr(raw.description),
    imageStyle: toStr(raw.imageStyle),
  };
}

async function main(): Promise<void> {
  switch (command) {
    case "upload": {
      const [inputFile] = args;
      const bookId = inputFile ? parseInputYml(inputFile).id : undefined;
      await upload(bookId);
      break;
    }
    case "story": {
      const [inputFile] = args;
      if (!inputFile) {
        console.error("エラー: story コマンドには inputFile が必要です");
        usage();
      }
      const { id, description } = parseInputYml(inputFile);
      await new BookGenerator().generateStory(id, description);
      break;
    }
    case "scenes": {
      const [inputFile] = args;
      if (!inputFile) {
        console.error("エラー: scenes コマンドには inputFile が必要です");
        usage();
      }
      const { id, title, imageStyle } = parseInputYml(inputFile);
      await new BookGenerator().generateScenes(id, title, imageStyle);
      break;
    }
    case "images": {
      throw new Error("images コマンドは現在サポートされていません。");
      // const [inputFile] = args;
      // if (!inputFile) {
      //   console.error("エラー: images コマンドには inputFile が必要です");
      //   usage();
      // }
      // const { id } = parseInputYml(inputFile);
      // await new BookGenerator().generateImages(id);
      // break;
    }
    case "audio": {
      const [inputFile] = args;
      if (!inputFile) {
        console.error("エラー: audio コマンドには inputFile が必要です");
        usage();
      }
      const { id } = parseInputYml(inputFile);
      await new BookGenerator().generateAudio(id);
      break;
    }
    default:
      console.error(`エラー: 不明なコマンド "${command ?? ""}"`);
      usage();
  }

  console.log("\n✓ Done.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
