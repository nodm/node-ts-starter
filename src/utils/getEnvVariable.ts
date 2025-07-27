import 'dotenv/config';

export function getEnvVariable(key: string): string;
export function getEnvVariable(key: string, isOptional: true): string | undefined;
export function getEnvVariable(key: string, isOptional = false): string | undefined {
  if (!isOptional && !Object.prototype.hasOwnProperty.call(process.env, key)) {
    throw new Error(`[getEnvVariable] Environment variable ${key} is not defined`);
  }
  return process.env[key];
}
