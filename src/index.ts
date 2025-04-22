import { getEnvVariable, registerSignalHandlers } from './utils/index.ts';

const defaultName = getEnvVariable('NAME', false);

export default async function run(name = defaultName): Promise<void> {
  console.log(`Hello, ${name}!`);
}

registerSignalHandlers();

await run();
