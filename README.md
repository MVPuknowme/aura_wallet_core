
# Aura Wallet Core

Aura Wallet Core is a library designed to simplify the creation and management of Aura cryptocurrency wallets within your application. This library provides an abstract interface for creating, restoring, and managing Aura cryptocurrency wallets, allowing for seamless integration into your projects.

## Table of Contents

- [Aura Wallet Core](#aura-wallet-core)
  - [Table of Contents](#table-of-contents)
  - [Roadmap](#roadmap)
  - [Getting Started](#getting-started)
  - [Basic Usage](#basic-usage)
    - [Creating a New Aura Wallet](#creating-a-new-aura-wallet)
    - [Restoring an Aura Wallet](#restoring-an-aura-wallet)
    - [Loading a Stored Aura Wallet](#loading-a-stored-aura-wallet)
    - [Removing an Aura Wallet](#removing-an-aura-wallet)
    - [Using the Aura Wallet](#using-the-aura-wallet)
      - [Creating a Transaction](#creating-a-transaction)
      - [Submitting a Transaction](#submitting-a-transaction)
      - [Checking Wallet Balance](#checking-wallet-balance)
      - [Checking Wallet Transaction History](#checking-wallet-transaction-history)
      - [Querying Smart Contracts](#querying-smart-contracts)
      - [Verifying Transaction Status](#verifying-transaction-status)
      - [Getting Wallet Passphrase](#getting-wallet-passphrase)
  - [Documentation](#documentation)
  - [Issues and Feedback](#issues-and-feedback)
  - [License](#license)
  - [Dependency lockfile](#dependency-lockfile)
  - [Scheduled weekly email workflow](#scheduled-weekly-email-workflow)
  - [Built-in token geo analytics](#built-in-token-geo-analytics)
  - [Deployment workflow](#deployment-workflow)
  - [Build workflow](#build-workflow)
  - [SkyGrid Edge command center](#skygrid-edge-command-center)

## Roadmap

- [x] Create HDWallet
- [x] Restore HDWallet
- [x] Check Wallet Balance
- [x] Check Wallet History
- [x] Make(Sign) / Send transaction
- [ ] Option for secure storage with Biometric Authentication

## Getting Started

To begin using Aura Wallet Core in your project, follow these steps:

1. Install the Dart SDK if it is not already available on your machine. You can install it locally into this repository by running:

   ```bash
   ./scripts/install_dart.sh
   export PATH="$(pwd)/.dart-sdk/bin:$PATH"
   dart --version
   ```

2. Add `aura_wallet_core` to your project's dependencies by adding the following line to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     aura_wallet_core: ^latest_version
   ```

3. Run the `flutter pub get` command to install the library.

## Dependency lockfile

The repository tracks `pubspec.lock` for CI dependency verification. Regenerate it with `flutter pub get` after installing the Dart/Flutter SDK so it reflects the versions resolved in your environment.


## Built-in token geo analytics

Aura Wallet Core now includes built-in token geo analytics so integrators can summarize token exposure by geography without adding a separate analytics package. Configure the analytics engine when creating `AuraWalletCore`, then pass your holdings into `analyzeTokenGeography`.

```dart
final core = AuraWalletCore.create(
  environment: AuraWalletCoreEnvironment.production,
  tokenAnalyticsConfig: const TokenAnalyticsConfig(
    providerName: 'BuiltInGeoAnalytics',
    topRegionsLimit: 3,
  ),
);

final analysis = core.analyzeTokenGeography(const <TokenHolding>[
  TokenHolding(symbol: 'AURA', amount: 120, unitPrice: 0.45, geography: 'APAC'),
  TokenHolding(symbol: 'ATOM', amount: 8, unitPrice: 9.8, geography: 'NA'),
  TokenHolding(symbol: 'USDC', amount: 50, unitPrice: 1, geography: 'EU'),
]);
```

The returned `TokenGeoAnalysis` includes total market value, the dominant region, a capped list of the highest-value regional breakdowns, a diversification score, and a human-readable insight string that can be used in dashboards or reports.

## Scheduled weekly email workflow

A GitHub Actions workflow sends a weekly status email every Monday at 12:00 UTC (and can also be triggered manually). Configure the following repository secrets so the workflow can authenticate with your SMTP provider:

- `EMAIL_SERVER_ADDRESS`: SMTP server hostname
- `EMAIL_SERVER_PORT`: SMTP server port (for example, `465` or `587`)
- `EMAIL_USERNAME`: SMTP username
- `EMAIL_PASSWORD`: SMTP password or app password
- `EMAIL_FROM_ADDRESS`: Email address to appear in the From header
- `EMAIL_TO_RECIPIENTS`: Comma-separated list of recipient addresses

You can customize the email subject, body, or schedule in `.github/workflows/weekly-email.yml`. Manual `workflow_dispatch` runs accept an optional `dry_run` input (`true`/`false`), which lets you preview the workflow logs without actually sending an email. The workflow uses a `concurrency` group to ensure only one weekly email run is active at a time.



## SkyGrid preflight health standard (Gold/Silver/Bronze)

Use the following approved wording in client-facing proof, invoices, and preflight summaries. The claims are intentionally tied to measurable signals already produced by the runtime checks, validator heartbeat payload, and ledger trace outputs.

- **Gold health standard**: "All required preflight checks passed with no blocking findings. Validator heartbeat remained online with trust score at or above 0.90 and p95 latency at or below 200 ms during the measured window. Ledger and receipt trace evidence was generated without fallback-only status."
- **Silver health standard**: "Required preflight checks passed with minor non-blocking findings. Validator heartbeat remained online with trust score from 0.75 to 0.89 and p95 latency from 201 ms to 350 ms during the measured window. Ledger and receipt trace evidence was generated, including documented fallbacks where applicable."
- **Bronze health standard**: "Core preflight checks completed, but one or more quality targets remained below preferred thresholds. Validator heartbeat was intermittent or recorded trust score from 0.60 to 0.74, or p95 latency from 351 ms to 600 ms during the measured window. Ledger and receipt trace evidence exists, and open remediation items are attached to this report or invoice."

### Unsupported wording to avoid

Do not use absolute claims such as "guaranteed uptime", "zero risk", "fully secure", or "production perfect" in invoice-ready proof. Replace them with the measurable Gold/Silver/Bronze statements above plus the exact observation window and metric values.

## Deployment workflow

Use the manual `Deploy` GitHub Actions workflow to build a release-ready Aura Wallet Core artifact. The workflow installs Flutter, resolves dependencies, verifies formatting, analyzes the package, runs tests, generates Dart API documentation, and uploads release archives plus SHA-256 checksums as workflow artifacts.

To publish those archives to a GitHub Release, run the workflow with `dry_run` set to `false` and provide the target `release_tag` (for example, `v0.0.1`). Dry runs keep the generated archives attached only to the workflow run, which is useful for validating a deployment before publishing.

## Build workflow

The repository build workflow is defined in `.github/workflows/dart.yml`. It runs on pushes and pull requests targeting `dev`, and now uses a `concurrency` group so only the latest build for the same ref stays active. Older in-progress runs for that ref are cancelled automatically to avoid duplicate GitHub Actions builds blocking each other.


## SkyGrid Edge command center

Aura Wallet Core now includes a dashboard-first SkyGrid command center standard for preparing Aura-Core / SkyGrid build and L2 execution artifacts. The exported `SkyGridCommandCenterService` builds a review-only preview that includes Helm chart status, validation commands, L2 script artifact metadata, redacted operator payloads, and receipt records.

Repository artifacts follow the issue #8 target structure:

- `dashboard/command-center/` documents the Edge-style operator control surface.
- `dashboard/validation-panel/` lists lint, render, dry-run, and L2 review checks that must pass before execution.
- `dashboard/deployment-review/` documents manifest and intent review expectations.
- `dashboard/receipts/` documents post-submit receipt display requirements.
- `helm/aura-core-autodrill/` contains the review-first Helm starter chart.
- `scripts/l2/` contains reviewable JavaScript modules for preparing, signing, submitting, and verifying L2 intents without automatic wallet execution.
- `api/drill-onramp`, `api/drill-offramp`, and `api/status` document the dashboard API lanes.

The Web3 browser or wallet lane should be used only for explicit signing, transaction submission, and receipt verification after generated payloads have been reviewed.

## Basic Usage

### Creating a New Aura Wallet

```dart
import 'package:aura_wallet_core/aura_wallet_core.dart';

final AuraWalletCore auraWalletCore = AuraWalletCore.create(
  environment: AuraWalletCoreEnvironment.production,
  biometricOptions: BiometricOptions(
    requestTitle: 'Unlock wallet',
    requestSubtitle: 'Use Face ID / Touch ID to unlock this account',
    authenticationTimeOut: 10, // 10 seconds timeout
  ),
);

final comprehensiveWallet = await auraWalletCore.createRandomHDWallet();
```

> **iOS biometric behavior:** Biometric prompts protect wallet secret reads (for example, restoring and signing access), not every non-sensitive lookup. This keeps day-to-day account list access fast while still requiring the enrolled owner biometric (Face ID / Touch ID) before sensitive wallet operations can continue.

### Restoring an Aura Wallet

```dart
final passPhrase = "your_recovery_passphrase";

final wallet = await walletCore.restoreHDWallet(
  passPhrase: passPhrase,
  walletName: "my_aura_wallet", // Optional wallet name
);
```

### Loading a Stored Aura Wallet

```dart
final walletName = "my_aura_wallet"; // Optional wallet name

final wallet = await walletCore.loadStoredWallet(
  walletName: walletName,
);

if (wallet != null) {
  // Wallet loaded successfully
} else {
  // Wallet not found
}
```

### Removing an Aura Wallet

```dart
final walletName = "my_aura_wallet"; // Optional wallet name

await walletCore.removeWallet(
  walletName: walletName,
);
```

### Using the Aura Wallet

With the `AuraWallet` instance obtained from Aura Wallet Core, you can perform various wallet-related operations, such as creating transactions, checking balances, and more.

#### Creating a Transaction

You can create a new transaction and sign it using the `makeTransaction` method. Provide the recipient's address, amount, and fee. You can also include an optional memo:

```dart
final Tx transaction = await auraWallet.makeTransaction(
  toAddress: 'recipient_address',
  amount: '100 AURA', // The amount to send.
  fee: '1 AURA', // Transaction fee.
  memo: 'Optional memo', // Optional memo field.
);
```

#### Submitting a Transaction

Once you've created a transaction, you can submit it to the Aura network using the `submitTransaction` method. Pass the signed transaction obtained in the previous step:

```dart
final bool isTransactionSuccessful = await auraWallet.submitTransaction(
  signedTransaction: transaction,
);
```

#### Checking Wallet Balance

To check the balance of your wallet, use the `checkWalletBalance` method:

```dart
final String balance = await auraWallet.checkWalletBalance();
```

#### Checking Wallet Transaction History

You can retrieve the transaction history of your wallet with the `checkWalletHistory` method, which returns a list of `AuraTransaction` objects:

```dart
final List<AuraTransaction> transactionHistory = await auraWallet.checkWalletHistory();
```

#### Querying Smart Contracts

With Aura Wallet, you can interact with smart contracts on the Aura network. Use the following methods to make interactive queries and execute smart contracts:

- `makeInteractiveQuerySmartContract`: Make an interactive query to a smart contract by providing the contract address and a query map.

- `makeInteractiveWriteSmartContract`: Execute a smart contract by providing the contract address, an execution message, and optional funds and fees.

#### Verifying Transaction Status

You can verify the status of a contract execution by providing its transaction hash using the `verifyTxHash` method:

```dart
final bool isTransactionSuccessful = await auraWallet.verifyTxHash(
  txHash: 'transaction_hash',
);
```

#### Getting Wallet Passphrase

To retrieve the mnemonic passphrase of the wallet user, use the `getWalletPassPhrase` method. This can be useful for certain operations requiring user authorization.

```dart
final String? mnemonicPassphrase = await auraWallet.getWalletPassPhrase();
```

## Documentation

For detailed documentation and examples, please visit the [library's documentation on pub.dev](https://pub.dev/packages/aura_wallet_core).

## Issues and Feedback

Please report any issues or provide feedback on [GitHub](https://github.com/aura-nw/aura-wallet-core).

## License

This library is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## SKYGRID/Aura-Core Identity Gate Bot

A Next.js MVP for consent-based pre-contact verification lives in `identity-gate-bot/`. See `identity-gate-bot/README.md` for setup, privacy boundaries, Prisma schema, API routes, and admin review flow.
