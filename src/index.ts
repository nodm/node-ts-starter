import {getEnvVariable} from './utils';

const defaultName = getEnvVariable('NAME', false);

export default function run(name = defaultName): void {
  console.log(`Hello, ${name}!`);
}

run();
