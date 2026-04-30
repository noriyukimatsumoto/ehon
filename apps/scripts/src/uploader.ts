import "dotenv/config";
import { Storage } from "@google-cloud/storage";
import archiver from "archiver";
import * as fs from "fs";
import * as path from "path";

const BUCKET_NAME =
  process.env.GCS_BUCKET ??
  (() => {
    throw new Error("GCS_BUCKET is required");
  })();
const GCS_PREFIX = process.env.GCS_PREFIX ?? "books";
const BOOKS_DIR = path.resolve(
  process.env.BOOKS_DIR ?? path.join(__dirname, "..", "books"),
);

const storage = new Storage();

async function uploadFile(
  localPath: string,
  destination: string,
  contentType: string,
): Promise<void> {
  const bucket = storage.bucket(BUCKET_NAME);
  await bucket.upload(localPath, { destination, metadata: { contentType } });
  console.log(`  uploaded: ${destination}`);
}

// zip に含めるファイル・ディレクトリ（bookDir からの相対パス）
const ZIP_INCLUDES = ["book.json", "cover.jpg", "images", "audios"];

async function uploadZip(bookDir: string, destination: string): Promise<void> {
  const bucket = storage.bucket(BUCKET_NAME);
  const file = bucket.file(destination);
  const writeStream = file.createWriteStream({
    metadata: { contentType: "application/zip" },
  });
  const archive = archiver("zip", { zlib: { level: 9 } });

  await new Promise<void>((resolve, reject) => {
    writeStream.on("finish", resolve);
    writeStream.on("error", reject);
    archive.on("error", reject);
    archive.pipe(writeStream);

    for (const entry of ZIP_INCLUDES) {
      const fullPath = path.join(bookDir, entry);
      if (!fs.existsSync(fullPath)) continue;
      if (fs.statSync(fullPath).isDirectory()) {
        archive.directory(fullPath, entry);
      } else {
        archive.file(fullPath, { name: entry });
      }
    }

    archive.finalize();
  });

  console.log(`  uploaded: ${destination}`);
}

async function uploadOne(bookId: string): Promise<void> {
  const bookDir = path.join(BOOKS_DIR, bookId);
  console.log(`[${bookId}]`);

  const coverPath = path.join(bookDir, "cover.jpg");
  if (fs.existsSync(coverPath)) {
    await uploadFile(
      coverPath,
      `${GCS_PREFIX}/${bookId}/cover.jpg`,
      "image/jpeg",
    );
  }

  await uploadZip(bookDir, `${GCS_PREFIX}/${bookId}/data.zip`);
}

export async function upload(bookId?: string): Promise<void> {
  if (!fs.existsSync(BOOKS_DIR)) {
    throw new Error(`BOOKS_DIR not found: ${BOOKS_DIR}`);
  }

  if (bookId) {
    await uploadOne(bookId);
    return;
  }

  const bookIds = fs
    .readdirSync(BOOKS_DIR, { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => e.name);

  if (bookIds.length === 0) {
    console.log("No books found.");
    return;
  }

  console.log(
    `Uploading ${bookIds.length} book(s) to gs://${BUCKET_NAME}/${GCS_PREFIX}/\n`,
  );
  for (const id of bookIds) {
    await uploadOne(id);
  }
}
