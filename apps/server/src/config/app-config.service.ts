import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AppConfigService {
  constructor(private readonly config: ConfigService) {}

  get gcsBaseUrl(): string {
    return this.config.getOrThrow<string>('GCS_BASE_URL');
  }
}
