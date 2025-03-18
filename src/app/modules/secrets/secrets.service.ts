import {
  Injectable,
  OnModuleInit,
  UnprocessableEntityException,
} from '@nestjs/common'
import { GetParameterCommand, SSMClient } from '@aws-sdk/client-ssm'
import { ConfigService } from '@nestjs/config'

interface Auth0Secrets {
  clientId: string
  clientSecret: string
  domain: string
  audience: string
}

@Injectable()
export class SecretsService implements OnModuleInit {
  private ssmClient: SSMClient
  private secrets: Auth0Secrets | null = null

  constructor(private configService: ConfigService) {
    this.ssmClient = new SSMClient({
      region: this.configService.get<string>('AWS_REGION'),
    })
  }

  async onModuleInit() {
    await this.loadSecrets()
  }

  getSecret(key: keyof Auth0Secrets): string {
    if (!this.secrets) {
      throw new UnprocessableEntityException('Secrets have not been loaded.')
    }

    if (!(key in this.secrets)) {
      throw new UnprocessableEntityException(
        `Secret key "${key}" does not exist.`,
      )
    }

    return this.secrets[key]
  }

  private async getParameter(
    name: string,
    withDecryption = true,
  ): Promise<string> {
    const command = new GetParameterCommand({
      Name: name,
      WithDecryption: withDecryption,
    })
    const response = await this.ssmClient.send(command)
    return response.Parameter?.Value || ''
  }

  private async loadSecrets() {
    const awsStage = this.configService.get<string>('AWS_STAGE', 'dev')
    const appSecretParamName = this.configService.get<string>(
      'APP_SECRET_PARAM_NAME',
      `finance-service-client-secret-${awsStage}`,
    )

    try {
      const secretString = await this.getParameter(appSecretParamName)
      this.secrets = JSON.parse(secretString) as unknown as Auth0Secrets
    } catch (error) {
      console.error('Failed to fetch or parse secrets:', error)
      this.secrets = null
    }
  }
}
