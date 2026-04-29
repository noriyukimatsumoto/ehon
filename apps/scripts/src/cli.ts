import "dotenv/config";
import { BookGenerator } from "./generate-book";
import { upload } from "./uploader";

const [, , command, ...args] = process.argv;

function usage(): void {
  console.error(`
使い方: ts-node src/cli.ts <command> [options]

Commands:
  upload [bookId]           ファイルをGCSにアップロードする（bookId省略時は全冊）
  story  <bookId> <title>   物語テキスト・JSON・XMLを生成する (step1~5)
  images <bookId>           画像プロンプトと画像を生成する (step6~7)
  audio  <bookId>           音声ファイルを生成する (step8)

例:
  ts-node src/cli.ts story  kaeru-no-osama "カエルの王様"
  ts-node src/cli.ts images kaeru-no-osama
  ts-node src/cli.ts audio  kaeru-no-osama
  ts-node src/cli.ts upload kaeru-no-osama
  ts-node src/cli.ts upload
`);
  process.exit(1);
}

async function main(): Promise<void> {
  switch (command) {
    case "upload": {
      const bookId = args[0];
      await upload(bookId);
      break;
    }
    case "story": {
      const [bookId, ...titleParts] = args;
      const title = titleParts.join(" ");
      if (!bookId || !title) {
        console.error("エラー: story コマンドには bookId と title が必要です");
        usage();
      }
      await new BookGenerator().generateStory(bookId, title);
      break;
    }
    case "images": {
      const [bookId] = args;
      if (!bookId) {
        console.error("エラー: images コマンドには bookId が必要です");
        usage();
      }
      await new BookGenerator().generateImages(bookId);
      break;
    }
    case "audio": {
      const [bookId] = args;
      if (!bookId) {
        console.error("エラー: audio コマンドには bookId が必要です");
        usage();
      }
      await new BookGenerator().generateAudio(bookId);
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
