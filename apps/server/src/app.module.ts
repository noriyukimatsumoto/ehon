import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import * as path from 'path';
import { CatalogModule } from './catalog/catalog.module';

@Module({
  imports: [
    ServeStaticModule.forRoot({
      rootPath: path.join(process.cwd(), 'books'),
      serveRoot: '/books',
      serveStaticOptions: { index: false },
    }),
    CatalogModule,
  ],
})
export class AppModule {}
