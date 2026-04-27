import { Controller, Get, Req } from '@nestjs/common';
import type { Request } from 'express';
import { CatalogService } from './catalog.service';

@Controller()
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('catalog')
  getCatalog(@Req() req: Request) {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    return this.catalogService.getCatalog(baseUrl);
  }
}
