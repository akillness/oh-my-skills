#!/usr/bin/env node
/**
 * Obsidian Plugin Boilerplate Generator
 * Validates metadata against Obsidian community submission rules
 * and generates a clean plugin project structure.
 *
 * Source: gapmiss/obsidian-plugin-skill (MIT)
 */

'use strict';

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = (q) => new Promise(resolve => rl.question(q, resolve));

// Validation rules matching Obsidian submission bot
const validators = {
  pluginId: (id) => {
    if (!id) return 'Plugin ID is required';
    if (!/^[a-z0-9_-]+$/.test(id)) return 'Plugin ID must be lowercase alphanumeric with dashes/underscores only';
    if (/obsidian/i.test(id)) return 'Plugin ID must not contain "obsidian"';
    if (/-plugin$|_plugin$/i.test(id)) return 'Plugin ID must not end with "-plugin" or "_plugin"';
    if (id.length < 3) return 'Plugin ID must be at least 3 characters';
    return null;
  },
  pluginName: (name) => {
    if (!name) return 'Plugin name is required';
    if (/obsidian/i.test(name)) return 'Plugin name must not contain "Obsidian"';
    if (/plugin$/i.test(name)) return 'Plugin name must not end with "Plugin"';
    if (/^obsi/i.test(name)) return 'Plugin name must not start with "Obsi"';
    if (/dian$/i.test(name)) return 'Plugin name must not end with "dian"';
    return null;
  },
  description: (desc) => {
    if (!desc) return 'Description is required';
    if (/obsidian/i.test(desc)) return 'Description must not mention "Obsidian"';
    if (/^this plugin/i.test(desc)) return 'Description must not start with "This plugin"';
    if (!/[.?!)]$/.test(desc.trim())) return 'Description must end with . ? ! or )';
    if (desc.length > 250) return 'Description must be under 250 characters';
    return null;
  }
};

function validate(field, value) {
  const error = validators[field]?.(value);
  if (error) { console.error(`  ✗ ${error}`); return false; }
  console.log(`  ✓ Valid`);
  return true;
}

async function promptWithValidation(question, field) {
  while (true) {
    const value = (await ask(question)).trim();
    if (validate(field, value)) return value;
  }
}

function generateManifest(data) {
  return JSON.stringify({
    id: data.pluginId,
    name: data.pluginName,
    version: '1.0.0',
    minAppVersion: data.minVersion || '1.0.0',
    description: data.description,
    author: data.author,
    authorUrl: `https://github.com/${data.github}`,
    isDesktopOnly: false
  }, null, 2);
}

function generateMainTs(data) {
  const className = data.pluginName.replace(/[^a-zA-Z0-9]/g, '') + 'Plugin';
  return `import { Plugin } from 'obsidian';
import { ${className}Settings, DEFAULT_SETTINGS, ${className}SettingTab } from './settings';

export default class ${className} extends Plugin {
  settings: ${className}Settings;

  async onload() {
    await this.loadSettings();
    this.addSettingTab(new ${className}SettingTab(this.app, this));
  }

  onunload() {}

  async loadSettings() {
    this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
  }

  async saveSettings() {
    await this.saveData(this.settings);
  }
}
`;
}

function generateSettingsTs(data) {
  const className = data.pluginName.replace(/[^a-zA-Z0-9]/g, '') + 'Plugin';
  return `import { App, PluginSettingTab, Setting } from 'obsidian';
import type ${className} from './main';

export interface ${className}Settings {
  // Add your settings fields here
}

export const DEFAULT_SETTINGS: ${className}Settings = {
  // Add default values here
};

export class ${className}SettingTab extends PluginSettingTab {
  plugin: ${className};

  constructor(app: App, plugin: ${className}) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display(): void {
    const { containerEl } = this;
    containerEl.empty();
    // Add settings UI here
    new Setting(containerEl)
      .setName('Example setting')
      .setDesc('An example setting.')
      .addText(text => text
        .setPlaceholder('Enter value')
        .onChange(async (value) => {
          await this.plugin.saveSettings();
        }));
  }
}
`;
}

async function main() {
  console.log('=== Obsidian Plugin Boilerplate Generator ===');
  console.log('Validates against Obsidian community submission rules\n');

  // Check --validate-only flag
  if (process.argv.includes('--validate-only')) {
    if (!fs.existsSync('manifest.json')) {
      console.error('ERROR: No manifest.json found in current directory');
      process.exit(1);
    }
    const manifest = JSON.parse(fs.readFileSync('manifest.json', 'utf8'));
    console.log('Validating manifest.json...');
    let valid = true;
    console.log('\nPlugin ID:'); valid = validate('pluginId', manifest.id) && valid;
    console.log('Plugin Name:'); valid = validate('pluginName', manifest.name) && valid;
    console.log('Description:'); valid = validate('description', manifest.description) && valid;
    console.log('\n' + (valid ? '✓ All checks passed' : '✗ Validation failed'));
    process.exit(valid ? 0 : 1);
  }

  const pluginId = await promptWithValidation('Plugin ID (e.g. note-timer): ', 'pluginId');
  const pluginName = await promptWithValidation('Plugin Name (e.g. Note Timer): ', 'pluginName');
  const description = await promptWithValidation('Description (ends with .): ', 'description');
  const author = (await ask('Author name: ')).trim();
  const github = (await ask('GitHub username: ')).trim();
  const minVersion = (await ask('Min Obsidian version [1.0.0]: ')).trim() || '1.0.0';

  rl.close();

  const data = { pluginId, pluginName, description, author, github, minVersion };
  const outDir = path.join(process.cwd(), pluginId);

  if (fs.existsSync(outDir)) {
    console.log(`\nDirectory ${outDir} already exists — adding missing files only`);
  } else {
    fs.mkdirSync(outDir, { recursive: true });
    console.log(`\nCreating ${outDir}/`);
  }

  const files = {
    'manifest.json': generateManifest(data),
    'src/main.ts': generateMainTs(data),
    'src/settings.ts': generateSettingsTs(data),
    'styles.css': `/* ${pluginName} styles\n * Use Obsidian CSS variables for theme compatibility.\n * See: references/css-styling.md\n */\n`,
    'package.json': JSON.stringify({
      name: pluginId, version: '1.0.0', description,
      main: 'main.js', scripts: {
        dev: 'node esbuild.config.mjs', build: 'tsc -noEmit -skipLibCheck && node esbuild.config.mjs production',
        version: 'node version-bump.mjs && git add manifest.json versions.json'
      },
      devDependencies: {
        '@types/node': '^18.0.0', 'esbuild': '0.17.3',
        'obsidian': 'latest', 'tslib': '2.4.0', 'typescript': '4.7.4',
        'eslint': '^9.0.0', 'eslint-plugin-obsidianmd': '^0.1.9'
      }
    }, null, 2),
    'tsconfig.json': JSON.stringify({
      compilerOptions: {
        baseUrl: '.', inlineSourceMap: true, inlineSources: true,
        module: 'ESNext', target: 'ES2018', allowImportingTsExtensions: true,
        moduleResolution: 'bundler', importHelpers: true, noImplicitAny: true,
        noUnusedLocals: false, strictNullChecks: true, isolatedModules: true,
        lib: ['ES2018', 'DOM']
      }, include: ['**/*.ts']
    }, null, 2),
    'versions.json': JSON.stringify({ '1.0.0': minVersion }, null, 2),
    '.gitignore': 'node_modules\nmain.js\n*.js.map\n'
  };

  fs.mkdirSync(path.join(outDir, 'src'), { recursive: true });

  for (const [file, content] of Object.entries(files)) {
    const filePath = path.join(outDir, file);
    if (!fs.existsSync(filePath)) {
      fs.mkdirSync(path.dirname(filePath), { recursive: true });
      fs.writeFileSync(filePath, content);
      console.log(`  ✓ ${file}`);
    } else {
      console.log(`  - ${file} (already exists, skipped)`);
    }
  }

  console.log('\n=== Plugin created successfully ===');
  console.log(`\nNext steps:`);
  console.log(`  cd ${pluginId}`);
  console.log(`  npm install`);
  console.log(`  npm run dev         # start watch mode`);
  console.log(`  npx eslint src/     # validate code`);
}

main().catch(err => { console.error(err); process.exit(1); });
