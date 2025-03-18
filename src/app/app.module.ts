import { Module } from '@nestjs/common'

import { RedisCacheModule } from '@modules'
import { ConfigModule } from '@nestjs/config'
import { SecretsModule } from '@app/modules/secrets/secrets.module'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    SecretsModule,
    RedisCacheModule,
  ],
})
export class AppModule {}
