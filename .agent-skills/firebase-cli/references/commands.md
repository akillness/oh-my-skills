# Firebase CLI — Complete Command Reference

> Source: https://firebase.google.com/docs/cli | firebase-tools v13.x
> Last updated: 2026-03-13

---

## Global Flags

These flags apply to **any** Firebase CLI command.

| Flag | Description |
|------|-------------|
| `-P <id>`, `--project <id>` | Specify the Firebase project ID |
| `--account <email>` | Specify the account (email) to use |
| `--token <token>` | *(Deprecated)* Long-lived user token |
| `--debug` | Enable verbose debug output |
| `--json` | Output results as JSON |
| `--non-interactive` | Disable interactive prompts |
| `--interactive` | Force interactive mode |
| `-h`, `--help` | Display help for the command |

---

## Authentication

### `firebase login`

Authenticate to Firebase. Opens browser for OAuth.

```bash
firebase login
firebase login --no-localhost     # Copy-paste flow
firebase login --reauth           # Force re-authentication
```

| Flag | Description |
|------|-------------|
| `--no-localhost` | Use copy-paste instead of local server |
| `--reauth` | Force re-authentication |

### `firebase logout`

```bash
firebase logout
firebase logout --account user@example.com
```

### `firebase login:ci`

Generate a CI token (deprecated — use service accounts instead).

```bash
firebase login:ci
firebase login:ci --no-localhost
```

### `firebase login:add`

Add authorization for an additional Google account.

```bash
firebase login:add
```

### `firebase login:list`

List all authorized CLI accounts.

```bash
firebase login:list
```

### `firebase login:use`

Set default account for the current project directory.

```bash
firebase login:use user@example.com
```

### `firebase login:revoke`

Revoke credentials for an account.

```bash
firebase login:revoke user@example.com
```

---

## CI/CD Authentication

Priority order:
1. `GOOGLE_APPLICATION_CREDENTIALS` env var → service account JSON *(recommended)*
2. Local user login
3. `--token` / `FIREBASE_TOKEN` *(deprecated)*
4. Application Default Credentials (`gcloud auth application-default login`)

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
firebase deploy --non-interactive
```

---

## Project Management

### `firebase init`

Set up Firebase features in the current directory. Creates `firebase.json`.

```bash
firebase init
firebase init hosting
firebase init functions
firebase init firestore
firebase init database
firebase init storage
firebase init emulators
firebase init remoteconfig
firebase init hosting:github    # Set up GitHub Actions
firebase init apphosting
firebase init genkit
```

Available features: `hosting`, `functions`, `firestore`, `database`, `storage`, `emulators`, `remoteconfig`, `extensions`, `apphosting`, `dataconnect`, `genkit`

### `firebase use`

Manage active Firebase project and aliases.

```bash
firebase use                        # Show active project + aliases
firebase use <project_id>           # Set active project
firebase use <alias>                # Switch to alias
firebase use --add                  # Add new alias interactively
firebase use --clear                # Clear active project
firebase use --unalias <alias>      # Remove an alias
```

Aliases stored in `.firebaserc`.

### `firebase projects:list`

```bash
firebase projects:list
```

### `firebase projects:create`

```bash
firebase projects:create <project_id>
firebase projects:create --display-name "My App"
```

| Flag | Description |
|------|-------------|
| `-n`, `--display-name <name>` | Display name |

### `firebase projects:addfirebase`

Add Firebase to an existing GCP project.

```bash
firebase projects:addfirebase <gcp_project_id>
```

### `firebase open`

Open Firebase console for a resource.

```bash
firebase open hosting:site
firebase open database
firebase open auth
firebase open storage
firebase open functions
firebase open firestore
firebase open analytics
firebase open crashlytics
firebase open messaging
firebase open remoteconfig
```

---

## Apps

### `firebase apps:create`

```bash
firebase apps:create WEB "My Web App"
firebase apps:create ANDROID com.example.app
firebase apps:create IOS com.example.app
```

| Flag | Description |
|------|-------------|
| `-a`, `--package-name <name>` | Android package name |
| `-b`, `--bundle-id <id>` | iOS bundle ID |
| `-s`, `--app-store-id <id>` | iOS App Store ID |

### `firebase apps:list`

```bash
firebase apps:list
firebase apps:list ANDROID
firebase apps:list IOS
firebase apps:list WEB
```

### `firebase apps:sdkconfig`

Print app configuration (google-services.json, GoogleService-Info.plist, etc.).

```bash
firebase apps:sdkconfig
firebase apps:sdkconfig ANDROID <app_id>
firebase apps:sdkconfig WEB <app_id> --out config.js
```

| Flag | Description |
|------|-------------|
| `-a`, `--app <app_id>` | App ID |
| `-o`, `--out <filename>` | Write to file |

---

## Deploy Targets

Named aliases for specific resources (Hosting sites, DB instances, Storage buckets).

### `firebase target:apply`

```bash
firebase target:apply hosting TARGET_NAME RESOURCE_ID
firebase target:apply storage TARGET_NAME BUCKET_NAME
firebase target:apply database TARGET_NAME INSTANCE_NAME
```

### `firebase target:clear`

```bash
firebase target:clear hosting TARGET_NAME
```

### `firebase target:remove`

```bash
firebase target:remove hosting TARGET_NAME RESOURCE_ID
```

Targets stored in `.firebaserc` under `targets`.

---

## Deployment

### `firebase deploy`

Deploy to Firebase based on `firebase.json`.

```bash
firebase deploy
firebase deploy --only hosting
firebase deploy --only functions
firebase deploy --only firestore
firebase deploy --only database
firebase deploy --only storage
firebase deploy --only remoteconfig
firebase deploy --only extensions
firebase deploy --only apphosting

# Multiple targets (comma-separated)
firebase deploy --only hosting,functions
firebase deploy --only hosting,firestore,storage

# Sub-targets
firebase deploy --only functions:myFunction
firebase deploy --only functions:groupName
firebase deploy --only hosting:siteName
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only database:rules

# Exclude targets
firebase deploy --except functions
firebase deploy --except hosting,storage
```

**All `--only` targets:**

| Target | What deploys |
|--------|-------------|
| `hosting` | Hosting content + config |
| `hosting:<site_id>` | Specific site (multi-site) |
| `functions` | All Cloud Functions |
| `functions:<name>` | Specific function or group |
| `firestore` | Firestore rules + indexes |
| `firestore:rules` | Firestore rules only |
| `firestore:indexes` | Firestore indexes only |
| `database` | Realtime Database rules |
| `database:rules` | Database rules only |
| `storage` | Cloud Storage rules |
| `remoteconfig` | Remote Config template |
| `extensions` | All installed extensions |
| `apphosting` | App Hosting backend |

**All flags:**

| Flag | Description |
|------|-------------|
| `--only <targets>` | Comma-separated deploy targets |
| `--except <targets>` | Comma-separated targets to skip |
| `-m`, `--message <msg>` | Deploy message stored with the release |
| `--force` | Delete Functions not in local source; bypass prompts |
| `--non-interactive` | Disable interactive prompts |
| `--debug` | Verbose debug output |
| `--dry-run` | Preview without deploying |

### `firebase serve`

Local development server for Hosting + HTTPS-triggered Functions.

```bash
firebase serve
firebase serve --only hosting
firebase serve --only functions
firebase serve --only hosting,functions
firebase serve --host 0.0.0.0
firebase serve --port 5000
```

| Flag | Description |
|------|-------------|
| `--only <services>` | Limit to `hosting`, `functions` |
| `--host <host>` | Host to bind (default: `localhost`) |
| `-p`, `--port <port>` | Port to listen on (default: `5000`) |

---

## Firebase Emulator Suite

### `firebase emulators:start`

```bash
firebase emulators:start
firebase emulators:start --only hosting,functions,firestore
firebase emulators:start --import ./emulator-data
firebase emulators:start --import ./emulator-data --export-on-exit
firebase emulators:start --export-on-exit ./emulator-data
firebase emulators:start --inspect-functions
firebase emulators:start --inspect-functions 9229
```

| Flag | Description |
|------|-------------|
| `--only <emulators>` | Comma-separated emulators to start |
| `--import <dir>` | Import emulator data on startup |
| `--export-on-exit [dir]` | Export data on shutdown |
| `--inspect-functions [port]` | Node.js debugger for Functions (default: 9229) |
| `--log-verbosity <level>` | `DEBUG`, `INFO`, `QUIET`, `SILENT` |
| `--ui` / `--no-ui` | Enable/disable Emulator UI |

**Valid `--only` values**: `auth`, `functions`, `firestore`, `database`, `hosting`, `pubsub`, `storage`, `apphosting`, `eventarc`, `dataconnect`

**Default ports:**

| Emulator | Port |
|----------|------|
| Authentication | 9099 |
| Cloud Functions | 5001 |
| Firestore | 8080 |
| Realtime Database | 9000 |
| Hosting | 5000 |
| Pub/Sub | 8085 |
| Cloud Storage | 9199 |
| Emulator Suite UI | 4000 |

### `firebase emulators:exec`

Start emulators, run a script, then shut down.

```bash
firebase emulators:exec "npm test"
firebase emulators:exec --only firestore,auth "npm test"
firebase emulators:exec --import ./emulator-data "npm test"
firebase emulators:exec --export-on-exit ./emulator-data "npm test"
```

| Flag | Description |
|------|-------------|
| `--only <emulators>` | Emulators to start |
| `--import <dir>` | Import data before running |
| `--export-on-exit [dir]` | Export data after script |
| `--inspect-functions [port]` | Functions debugger |
| `--log-verbosity <level>` | Log verbosity |

### `firebase emulators:export`

Export data from running emulators.

```bash
firebase emulators:export ./emulator-data
firebase emulators:export ./emulator-data --force
```

### Setup emulator binaries

```bash
firebase setup:emulators:database    # Realtime Database emulator
firebase setup:emulators:firestore   # Firestore emulator
```

---

## Firebase Hosting

### `firebase hosting:channel:create`

```bash
firebase hosting:channel:create CHANNEL_ID
firebase hosting:channel:create staging --expires 7d
```

| Flag | Description |
|------|-------------|
| `-e`, `--expires <duration>` | Expiry duration: `12h`, `7d`, `2w`; max `30d` |
| `-s`, `--site <site_id>` | Target a specific site |

### `firebase hosting:channel:deploy`

```bash
firebase hosting:channel:deploy CHANNEL_ID
firebase hosting:channel:deploy staging --expires 7d
firebase hosting:channel:deploy new-feature --expires 24h --open
firebase hosting:channel:deploy staging --only my-site
```

| Flag | Description |
|------|-------------|
| `-e`, `--expires <duration>` | Channel expiry; default `7d`; max `30d` |
| `--only <targets>` | Restrict to specific site targets |
| `--open` | Open browser to channel URL after deploy |
| `--no-authorized-domains` | Skip syncing with Auth authorized domains |

Channel URL format: `https://PROJECT_ID--CHANNEL_ID-HASH.web.app`

### `firebase hosting:channel:delete`

```bash
firebase hosting:channel:delete CHANNEL_ID
firebase hosting:channel:delete staging --force
```

### `firebase hosting:channel:list`

```bash
firebase hosting:channel:list
firebase hosting:channel:list --site my-site
```

### `firebase hosting:channel:open`

```bash
firebase hosting:channel:open CHANNEL_ID
firebase hosting:channel:open live
```

### `firebase hosting:clone`

Clone a Hosting version between sites/channels.

```bash
firebase hosting:clone SOURCE_SITE:SOURCE_CHANNEL TARGET_SITE:TARGET_CHANNEL
firebase hosting:clone my-app:live my-app-staging:staging
```

### `firebase hosting:disable`

```bash
firebase hosting:disable
firebase hosting:disable --force
firebase hosting:disable --site my-site
```

### `firebase hosting:sites:create`

```bash
firebase hosting:sites:create SITE_ID
```

### `firebase hosting:sites:list`

```bash
firebase hosting:sites:list
```

### `firebase hosting:sites:delete`

```bash
firebase hosting:sites:delete SITE_ID --force
```

---

## Cloud Functions

### `firebase functions:list`

```bash
firebase functions:list
```

### `firebase functions:log`

```bash
firebase functions:log
firebase functions:log --only myFunction
firebase functions:log --lines 50
firebase functions:log --open
```

| Flag | Description |
|------|-------------|
| `--only <name>` | Filter by function name |
| `-n`, `--lines <n>` | Number of lines (default: 35) |
| `--open` | Open console log viewer |

### `firebase functions:delete`

```bash
firebase functions:delete myFunction
firebase functions:delete myFunction --region us-east1
firebase functions:delete myFunction --force
```

| Flag | Description |
|------|-------------|
| `--region <region>` | Function region (e.g., `us-central1`) |
| `--force` | Skip confirmation |

### `firebase functions:shell`

```bash
firebase functions:shell
firebase functions:shell --port 5001
```

### `firebase functions:config:set` *(1st gen only)*

```bash
firebase functions:config:set api.key="THE_API_KEY" api.url="https://api.example.com"
```

### `firebase functions:config:get` *(1st gen only)*

```bash
firebase functions:config:get
firebase functions:config:get api
firebase functions:config:get api.key
```

### `firebase functions:config:unset` *(1st gen only)*

```bash
firebase functions:config:unset api.key
```

### `firebase functions:config:clone` *(1st gen only)*

```bash
firebase functions:config:clone --from SOURCE_PROJECT_ID
```

### `firebase functions:secrets:set`

```bash
firebase functions:secrets:set SECRET_NAME
```

### `firebase functions:secrets:get`

```bash
firebase functions:secrets:get SECRET_NAME
```

### `firebase functions:secrets:access`

```bash
firebase functions:secrets:access SECRET_NAME
firebase functions:secrets:access SECRET_NAME@VERSION
```

### `firebase functions:secrets:prune`

```bash
firebase functions:secrets:prune
firebase functions:secrets:prune --force
```

### `firebase functions:secrets:destroy`

```bash
firebase functions:secrets:destroy SECRET_NAME
firebase functions:secrets:destroy SECRET_NAME@VERSION --force
```

---

## Realtime Database

### `firebase database:get`

```bash
firebase database:get /path
firebase database:get /messages --pretty
firebase database:get /messages --shallow
firebase database:get /messages --export
firebase database:get /messages -o messages.json
firebase database:get /messages --instance my-db
firebase database:get /messages --order-by-child score --limit-to-last 10
```

| Flag | Description |
|------|-------------|
| `--pretty` | Pretty-print JSON output |
| `--shallow` | Top-level keys only |
| `--export` | Include `.priority` values |
| `-o`, `--output <file>` | Write to file |
| `-i`, `--instance <name>` | Non-default DB instance |
| `--order-by-child <key>` | Order by child key |
| `--order-by-key` | Order by key |
| `--order-by-value` | Order by value |
| `--limit-to-first <n>` | First N results |
| `--limit-to-last <n>` | Last N results |
| `--start-at <value>` | Results starting at value |
| `--end-at <value>` | Results ending at value |
| `--equal-to <value>` | Exact match |

### `firebase database:set`

```bash
firebase database:set /path data.json
firebase database:set /path --data '{"key":"value"}'
echo '{"foo":"bar"}' | firebase database:set /import --confirm
```

| Flag | Description |
|------|-------------|
| `-d`, `--data <json>` | Inline JSON data |
| `-y`, `--confirm` | Skip confirmation |
| `-i`, `--instance <name>` | Non-default DB instance |

### `firebase database:push`

```bash
firebase database:push /messages data.json
firebase database:push /messages --data '{"name":"Doug","text":"Hello"}'
```

### `firebase database:update`

```bash
firebase database:update /users/uid --data '{"name":"New Name"}'
firebase database:update /path data.json
```

### `firebase database:remove`

```bash
firebase database:remove /path
firebase database:remove / --confirm    # WARNING: deletes entire database
```

### `firebase database:profile`

```bash
firebase database:profile
firebase database:profile --duration 30
firebase database:profile --output report.json
firebase database:profile --raw
```

| Flag | Description |
|------|-------------|
| `-d`, `--duration <secs>` | Profile duration (default: 120) |
| `-o`, `--output <file>` | Write report to file |
| `--raw` | Raw operation data |
| `-i`, `--instance <name>` | Non-default DB instance |

### `firebase database:instances:create`

```bash
firebase database:instances:create INSTANCE_NAME
firebase database:instances:create my-db --location us-central1
```

### `firebase database:instances:list`

```bash
firebase database:instances:list
```

### `firebase database:settings:get`

```bash
firebase database:settings:get /settings/path
```

### `firebase database:settings:set`

```bash
firebase database:settings:set /settings/path VALUE
```

---

## Cloud Firestore

### `firebase firestore:delete`

```bash
firebase firestore:delete COLLECTION_PATH
firebase firestore:delete COLLECTION_PATH/DOCUMENT_ID
firebase firestore:delete COLLECTION_PATH --recursive
firebase firestore:delete --all-collections --recursive --force
```

| Flag | Description |
|------|-------------|
| `-r`, `--recursive` | Recursively delete subcollections |
| `--all-collections` | Delete all Firestore data |
| `-y`, `--force` | Skip confirmation |
| `--database <id>` | Target named database |

### `firebase firestore:indexes`

```bash
firebase firestore:indexes
firebase firestore:indexes --database my-db
```

### `firebase firestore:rules:get`

```bash
firebase firestore:rules:get
```

### `firebase firestore:rules:stage`

```bash
firebase firestore:rules:stage RULES_FILE
```

### `firebase firestore:rules:release`

```bash
firebase firestore:rules:release
firebase firestore:rules:release RULES_FILE
```

---

## Firebase Authentication

### `firebase auth:import`

```bash
firebase auth:import users.json
firebase auth:import users.csv

# SCRYPT (Firebase native)
firebase auth:import users.json \
  --hash-algo=SCRYPT \
  --hash-key=<base64-key> \
  --salt-separator=<base64-separator> \
  --rounds=8 \
  --mem-cost=8

# BCRYPT
firebase auth:import users.json --hash-algo=BCRYPT
```

**Supported hash algorithms**: `SCRYPT`, `STANDARD_SCRYPT`, `HMAC_SHA256`, `HMAC_SHA512`, `HMAC_SHA1`, `HMAC_MD5`, `MD5`, `SHA1`, `SHA256`, `SHA512`, `BCRYPT`, `PBKDF_SHA1`, `PBKDF2_SHA256`

| Flag | Description |
|------|-------------|
| `--hash-algo <algo>` | Hash algorithm |
| `--hash-key <key>` | Signer key (base64) |
| `--salt-separator <sep>` | Salt separator (base64) |
| `--rounds <n>` | Hash rounds |
| `--mem-cost <n>` | Memory cost |
| `--parallelization <n>` | Parallelization (STANDARD_SCRYPT) |
| `--block-size <n>` | Block size (STANDARD_SCRYPT) |
| `--dk-len <n>` | Derived key length (STANDARD_SCRYPT) |

### `firebase auth:export`

```bash
firebase auth:export users.json
firebase auth:export users.csv --format CSV
```

| Flag | Description |
|------|-------------|
| `--format <fmt>` | `JSON` (default) or `CSV` |

---

## Remote Config

### `firebase remoteconfig:get`

```bash
firebase remoteconfig:get
firebase remoteconfig:get --v 5
firebase remoteconfig:get --output config.json
```

| Flag | Description |
|------|-------------|
| `-v`, `--version-number <n>` | Retrieve specific version |
| `-o`, `--output <file>` | Write to file |

### `firebase remoteconfig:rollback`

```bash
firebase remoteconfig:rollback --version-number 5
firebase remoteconfig:rollback -v 5 --force
```

| Flag | Description |
|------|-------------|
| `-v`, `--version-number <n>` | **(Required)** Version to roll back to |
| `--force` | Skip confirmation |

### `firebase remoteconfig:versions:list`

```bash
firebase remoteconfig:versions:list
firebase remoteconfig:versions:list --limit 10
firebase remoteconfig:versions:list --limit 0    # All versions
```

### Remote Config Experiments / Rollouts

```bash
firebase remoteconfig:experiments:get EXPERIMENT_ID
firebase remoteconfig:experiments:list
firebase remoteconfig:experiments:delete EXPERIMENT_ID
firebase remoteconfig:rollouts:get ROLLOUT_ID
firebase remoteconfig:rollouts:list
firebase remoteconfig:rollouts:delete ROLLOUT_ID
```

---

## App Distribution

### `firebase appdistribution:distribute`

```bash
# Android
firebase appdistribution:distribute app-release.apk \
  --app "1:1234567890:android:abcd1234" \
  --release-notes "Bug fixes" \
  --testers "alice@example.com,bob@example.com" \
  --groups "qa-team,beta-users"

# iOS
firebase appdistribution:distribute MyApp.ipa \
  --app "1:1234567890:ios:abcd1234" \
  --release-notes-file ./release-notes.txt \
  --groups-file ./groups.txt

# With automated testing
firebase appdistribution:distribute app.apk \
  --app APP_ID \
  --test-devices "model=shiba,version=34,locale=en,orientation=portrait"
```

| Flag | Description |
|------|-------------|
| `--app <app_id>` | **(Required)** Firebase App ID |
| `--release-notes <notes>` | Release notes text |
| `--release-notes-file <path>` | Path to release notes file |
| `--testers <emails>` | Comma-separated tester emails |
| `--testers-file <path>` | File with tester emails |
| `--groups <aliases>` | Comma-separated group aliases |
| `--groups-file <path>` | File with group aliases |
| `--test-devices <spec>` | Device specs for automated testing |
| `--test-devices-file <path>` | File with device specifications |
| `--test-username <user>` | Username for login during tests |
| `--test-password <pass>` | Password for login |
| `--test-non-blocking` | Run tests asynchronously |
| `--debug` | Verbose debug output |

### Tester Management

```bash
firebase appdistribution:testers:list
firebase appdistribution:testers:list --group-alias qa-team
firebase appdistribution:testers:add alice@example.com --group-alias qa-team
firebase appdistribution:testers:add --file testers.txt
firebase appdistribution:testers:remove alice@example.com
firebase appdistribution:groups:list
firebase appdistribution:groups:create "QA Team" qa-team
firebase appdistribution:groups:delete qa-team
firebase appdistribution:testcases:export --output test-cases.yaml
firebase appdistribution:testcases:import test-cases.yaml
```

---

## Extensions

### `firebase ext:info`

```bash
firebase ext:info publisher/extension-id
firebase ext:info firebase/delete-user-data@0.1.12
```

### `firebase ext:install`

```bash
firebase ext:install publisher/extension-id
firebase ext:install firebase/delete-user-data
firebase ext:install firebase/delete-user-data@0.1.12
firebase ext:install ./local/extension
```

### `firebase ext:list`

```bash
firebase ext:list
```

### `firebase ext:configure`

```bash
firebase ext:configure INSTANCE_ID
firebase ext:configure delete-user-data --params params.env
```

### `firebase ext:update`

```bash
firebase ext:update INSTANCE_ID
firebase ext:update delete-user-data
firebase ext:update delete-user-data@0.2.0 --force
```

### `firebase ext:uninstall`

```bash
firebase ext:uninstall INSTANCE_ID
firebase ext:uninstall delete-user-data --force
```

### `firebase ext:export`

```bash
firebase ext:export
```

### Extension Developer Commands

```bash
firebase ext:dev:upload publisher/extension-id
firebase ext:dev:list publisher
firebase ext:dev:deprecate publisher/extension-id@version "Reason"
firebase ext:dev:undeprecate publisher/extension-id@version
firebase ext:sdk:install publisher/extension-id
```

---

## App Hosting

### `firebase apphosting:backends:create`

```bash
firebase apphosting:backends:create
firebase apphosting:backends:create --location us-central1
firebase apphosting:backends:create --backend-id my-backend
firebase apphosting:backends:create --app <web_app_id>
```

### `firebase apphosting:backends:list`

```bash
firebase apphosting:backends:list
```

### `firebase apphosting:backends:delete`

```bash
firebase apphosting:backends:delete BACKEND_ID --location us-central1 --force
```

### `firebase apphosting:rollouts:create`

```bash
firebase apphosting:rollouts:create BACKEND_ID
firebase apphosting:rollouts:create BACKEND_ID --git-branch main
firebase apphosting:rollouts:create BACKEND_ID --git-commit <commit_sha>
firebase apphosting:rollouts:create BACKEND_ID --location us-central1
```

### App Hosting Secrets

```bash
firebase apphosting:secrets:set SECRET_NAME
firebase apphosting:secrets:grantaccess SECRET_NAME --backend BACKEND_ID
```

---

## Data Connect

```bash
firebase dataconnect:services:list
firebase dataconnect:sql:setup
firebase dataconnect:sdk:generate
```

---

## `firebase.json` Configuration Reference

```json
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [{ "key": "Cache-Control", "value": "max-age=31536000" }]
      }
    ],
    "cleanUrls": true,
    "trailingSlash": false
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs20"
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "database": {
    "rules": "database.rules.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "emulators": {
    "auth": { "port": 9099 },
    "functions": { "port": 5001 },
    "firestore": { "port": 8080 },
    "hosting": { "port": 5000 },
    "database": { "port": 9000 },
    "storage": { "port": 9199 },
    "ui": { "enabled": true, "port": 4000 },
    "singleProjectMode": true
  }
}
```

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `FIREBASE_TOKEN` | *(Deprecated)* Long-lived token from `login:ci` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON key |
| `HTTPS_PROXY` / `HTTP_PROXY` | Proxy URL |
| `FIREBASE_EMULATOR_HUB` | Emulator Hub address (e.g., `localhost:4400`) |
| `FIREBASE_AUTH_EMULATOR_HOST` | Auth emulator host:port |
| `FIRESTORE_EMULATOR_HOST` | Firestore emulator host:port |
| `FIREBASE_DATABASE_EMULATOR_HOST` | Database emulator host:port |
| `FIREBASE_STORAGE_EMULATOR_HOST` | Storage emulator host:port |
| `GCLOUD_PROJECT` / `FIREBASE_PROJECT` | Fallback project ID |

---

## Programmatic API (Node.js)

```javascript
const client = require("firebase-tools");

// List apps
client.apps.list("ANDROID", { project: "my-project" })
  .then(data => console.log(data));

// Deploy
client.deploy({
  project: "my-project",
  only: "hosting",
  token: process.env.FIREBASE_TOKEN  // or use service account
}).then(() => console.log("Deployed!"));
```

---

## Version Notes

| Feature | Notes |
|---------|-------|
| `functions:config:*` | Deprecated for 2nd gen; use `functions:secrets:*` |
| `--token` / `FIREBASE_TOKEN` | Deprecated; migrate to service accounts |
| `ext:dev:publish` | Deprecated; use `ext:dev:upload` |
| `firebase serve` | Primarily for Hosting + 1st gen HTTPS Functions |
| App Hosting | GA as of late 2024; requires `firebase init apphosting` |
| Node.js requirement | Node.js 18+ (LTS) recommended; 16+ minimum |
