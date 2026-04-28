import 'dotenv/config';
import { Storage } from '@google-cloud/storage';
import * as fs from 'fs';
import * as path from 'path';

const BUCKET_NAME = process.env.GCS_BUCKET ?? (() => { throw new Error('GCS_BUCKET is required'); })();
const GCS_PREFIX = process.env.GCS_PREFIX ?? 'books';
const BOOKS_DIR = path.resolve(process.env.BOOKS_DIR ?? path.join(__dirname, '..', 'books'));

const storage = new Storage();
const bucket = storage.bucket(BUCKET_NAME);

function walkFiles(dir: string): string[] {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    return entry.isDirectory() ? walkFiles(fullPath) : [fullPath];
  });
}

const CONTENT_TYPES: Record<string, string> = {
  '.xml': 'application/xml',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
};

function contentTypeOf(filePath: string): string {
  return CONTENT_TYPES[path.extname(filePath).toLowerCase()] ?? 'application/octet-stream';
}

async function uploadBook(bookId: string): Promise<void> {
  const bookDir = path.join(BOOKS_DIR, bookId);
  const files = walkFiles(bookDir);

  for (const filePath of files) {
    const relative = path.relative(bookDir, filePath).replace(/\\/g, '/');
    const destination = `${GCS_PREFIX}/${bookId}/${relative}`;

    await bucket.upload(filePath, {
      destination,
      metadata: { contentType: contentTypeOf(filePath) },
    });

    console.log(`  uploaded: ${destination}`);
  }
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
