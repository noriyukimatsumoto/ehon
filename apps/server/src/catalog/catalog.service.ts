import { Injectable, OnModuleInit } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

interface BookMeta {
  id: string;
  version: string;
  title: Record<string, string>;
  categoryId: string;
  categoryName: Record<string, string>;
}

@Injectable()
export class CatalogService implements OnModuleInit {
  private readonly booksDir = path.join(process.cwd(), 'books');
  private books: BookMeta[] = [];

  onModuleInit() {
    this.loadCatalog();
  }

  private loadCatalog() {
    if (!fs.existsSync(this.booksDir)) return;

    const entries = fs.readdirSync(this.booksDir, { withFileTypes: true });
    this.books = entries
      .filter((e) => e.isDirectory())
      .map((e) => {
        const metaPath = path.join(this.booksDir, e.name, 'meta.json');
        if (!fs.existsSync(metaPath)) return null;
        return JSON.parse(fs.readFileSync(metaPath, 'utf-8')) as BookMeta;
      })
      .filter((b): b is BookMeta => b !== null);
  }

  getCatalog(baseUrl: string) {
    // Reload on each request in development for hot-reloading of new books
    this.loadCatalog();

    const books = this.books.map((meta) => ({
      id: meta.id,
      version: meta.version,
      title: meta.title,
      categoryId: meta.categoryId,
      categoryName: meta.categoryName,
      xmlUrl: `${baseUrl}/books/${meta.id}/book.xml`,
      coverImageUrl: `${baseUrl}/books/${meta.id}/images/cover.jpg`,
      imageBaseUrl: `${baseUrl}/books/${meta.id}/images/`,
    }));

    return { books };
  }
}
