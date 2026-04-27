import { Injectable } from '@nestjs/common';
import { AppConfigService } from '../config/app-config.service';
import * as fs from 'fs';
import * as path from 'path';

interface BookMeta {
  id: string;
  version: string;
  title: Record<string, string>;
  categoryId: string;
  categoryName: Record<string, string>;
}

const catalogData = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'catalog.json'), 'utf-8'),
) as BookMeta[];

@Injectable()
export class CatalogService {
  constructor(private readonly config: AppConfigService) {}

  getCatalog() {
    const gcsBaseUrl = this.config.gcsBaseUrl;
    const books = catalogData.map((meta) => ({
      id: meta.id,
      version: meta.version,
      title: meta.title,
      categoryId: meta.categoryId,
      categoryName: meta.categoryName,
      xmlUrl: `${gcsBaseUrl}/${meta.id}/book.xml`,
      coverImageUrl: `${gcsBaseUrl}/${meta.id}/images/cover.jpg`,
      imageBaseUrl: `${gcsBaseUrl}/${meta.id}/images/`,
    }));

    return { books };
  }
}
