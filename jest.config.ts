import { pathsToModuleNameMapper } from 'ts-jest'
import tsconfigJson from './tsconfig.json'

const tsconfig = tsconfigJson as {
  compilerOptions: { paths: Record<string, string[]> }
}
const { compilerOptions } = tsconfig

export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/test', '<rootDir>/src'],
  moduleFileExtensions: ['ts', 'js', 'json'],
  moduleNameMapper: pathsToModuleNameMapper(compilerOptions?.paths ?? {}, {
    prefix: '<rootDir>/',
  }),
  testMatch: ['**/?(*.)+(spec|test|e2e-spec).ts'],
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  coverageReporters: ['json', 'lcov', 'text', 'clover'],
}
