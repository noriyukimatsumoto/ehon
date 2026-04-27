import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { CatalogModule } from './catalog/catalog.module';

@Module({
  imports: [AppConfigModule, CatalogModule],
})
export class AppModule {}
