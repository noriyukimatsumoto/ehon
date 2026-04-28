import 'dotenv/config';
import { Storage } from '@google-cloud/storage';
import archiver from 'archiver';
import * as fs from 'fs';
import * as path from 'path';

const BUCKET_NAME = process.env.GCS_BUCKET ?? (() => { throw new Error('GCS_BUCKET is required'); })();
const GCS_PREFIX = process.env.GCS_PREFIX ?? 'books';
const BOOKS_DIR = path.resolve(process.env.BOOKS_DIR ?? path.join(__dirname, '..', 'books'));

const storage = new Storage();
const bucket = storage.bucket(BUCKET_NAME);

async function uploadFile(localPath: string, destination: string, contentType: string): Promise<void> {
  await bucket.upload(localPath, { destination, metadata: { contentType } });
  console.log(`  uploaded: ${destination}`);
}

async function uploadZip(bookDir: string, destination: string): Promise<void> {
  const file = bucket.file(destination);
  const writeStream = file.createWriteStream({ metadata: { contentType: 'application/zip' } });
  const archive = archiver('zip', { zlib: { level: 9 } });

  await new Promise<void>((resolve, reject) => {
    writeStream.on('finish', resolve);
    writeStream.on('error', reject);
    archive.on('error', reject);
    archive.pipe(writeStream);
    archive.directory(bookDir, false);
    archive.finalize();
  });

  console.log(`  uploaded: ${destination}`);
}

async function uploadBook(bookId: string): Promise<void> {
  const bookDir = path.join(BOOKS_DIR, bookId);

  // cover.jpg を個別アップロード（カタログ表示用）
  const coverPath = path.join(bookDir, 'cover.jpg');
  if (fs.existsSync(coverPath)) {
    await uploadFile(coverPath, `${GCS_PREFIX}/${bookId}/cover.jpg`, 'image/jpeg');
  }

  // 書籍コンテンツ全体を zip にまとめてアップロード
  await uploadZip(bookDir, `${GCS_PREFIX}/${bookId}/data.zip`);
}

async function main(): Promise<void> {
  if (!fs.existsSync(BOOKS_DIR)) {
    throw new Error(`BOOKS_DIR not found: ${BOOKS_DIR}`);
  }

  const bookIds = fs
    .readdirSync(BOOKS_DIR, { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => e.name);

  if (bookIds.length === 0) {
    console.log('No books found.');
    return;
  }

  console.log(`Uploading ${bookIds.length} book(s) to gs://${BUCKET_NAME}/${GCS_PREFIX}/\n`);

  for (const bookId of bookIds) {
    console.log(`[${bookId}]`);
    await uploadBook(bookId);
  }

  console.log('\nDone.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
