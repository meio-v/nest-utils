import { Module } from '@nestjs/common'
import { CacheModule } from '@nestjs/cache-manager'
import KeyvRedis from '@keyv/redis'
import { ConfigModule, ConfigService } from '@nestjs/config'

@Module({
  imports: [
    CacheModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const redisUrl = `redis://${configService.get<string>('REDIS_HOST')}:${configService.get<number>('REDIS_PORT')}`
        const keyvStoreSettings = { store: new KeyvRedis(redisUrl) }
        return {
          store: keyvStoreSettings,
          ttl: configService.get<number>('CACHE_TTL', 3600) * 1000,
          isGlobal: true,
        }
      },
      inject: [ConfigService],
    }),
  ],
})
export class RedisCacheModule {}
