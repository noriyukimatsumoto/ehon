import "dotenv/config";
import * as fs from "fs";
import { BookGenerator } from "./generate-book";
import { upload } from "./uploader";

const [, , command, ...args] = process.argv;

function usage(): void {
  console.error(`
使い方: ts-node src/cli.ts <command> [options]

Commands:
  upload [inputFile]   ファイルをGCSにアップロードする（inputFile省略時は全冊）
  story  <inputFile>   物語テキスト・JSON・XMLを生成する (step1~5)
  images <inputFile>   画像プロンプトと画像を生成する (step6~7)
  audio  <inputFile>   音声ファイルを生成する (step8)

inputFile (YML形式):
  id: kaeru-no-osama
  title: カエルの王様
  imageStyle: 水彩画タッチの子ども向けイラスト
  hint:
    - グリム童話の「カエルの王様」
    - 魔法でカエルにされた王子の物語

例:
  ts-node src/cli.ts story  story.yml
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
  hint: string;
  imageStyle: string;
} {
  const lines = fs.readFileSync(filePath, "utf-8").split("\n");
  const scalars: Record<string, string> = {};
  const lists: Record<string, string[]> = {};
  let currentListKey: string | null = null;

  for (const line of lines) {
    const keyMatch = line.match(/^(\w+):\s*(.*)$/);
    if (keyMatch) {
      currentListKey = null;
      const key = keyMatch[1];
      const value = keyMatch[2].trim();
      if (value) {
        scalars[key] = value;
      } else {
        lists[key] = [];
        currentListKey = key;
      }
      continue;
    }
    const itemMatch = line.match(/^\s+-\s*(.+)$/);
    if (itemMatch && currentListKey) {
      lists[currentListKey].push(itemMatch[1].trim());
    }
  }

  const id = scalars.id;
  if (!id) throw new Error(`inputFile に id が見つかりません: ${filePath}`);
  const title = scalars.title;
  if (!title) throw new Error(`inputFile に title が見つかりません: ${filePath}`);

  let hint = "";
  if (scalars.hint) {
    hint = scalars.hint;
  } else if (lists.hint?.length) {
    hint = lists.hint.map((item) => `- ${item}`).join("\n");
  }

  const imageStyle = scalars.imageStyle;
  if (!imageStyle) throw new Error(`inputFile に imageStyle が見つかりません: ${filePath}`);

  return { id, title, hint, imageStyle };
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
      const { id, title, hint } = parseInputYml(inputFile);
      await new BookGenerator().generateStory(id, title, hint);
      break;
    }
    case "images": {
      const [inputFile] = args;
      if (!inputFile) {
        console.error("エラー: images コマンドには inputFile が必要です");
        usage();
      }
      const { id, imageStyle } = parseInputYml(inputFile);
      await new BookGenerator().generateImages(id, imageStyle);
      break;
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
