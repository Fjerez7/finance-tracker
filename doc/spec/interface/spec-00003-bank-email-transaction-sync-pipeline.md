---
id: spec-00003-bank-email-transaction-sync-pipeline
type: spec
code: "00003"
slug: bank-email-transaction-sync-pipeline
title: Bank Email Transaction Sync Pipeline Specification
description: Technical specification for the unattended bank email extraction pipeline using Google Apps Script, Gemini Flash, Cloud Firestore staging, and Flutter SQLite synchronization.
category: interface
created: 2026-09-12
updated: 2026-09-12
authors:
  - Fabian Jerez
tags:
  - automation
  - gmail
  - gemini
  - firestore
  - sqlite
  - sync
related:
  - spec-00001-estructura-de-carpetas-y-convenciones-flutter
  - spec-00002-functional-modules-and-product-requirements
supersedes: []
superseded_by: null
aliases:
  - "SPEC 00003: Bank Email Transaction Sync Pipeline Specification"
---

# SPEC 00003: Bank Email Transaction Sync Pipeline Specification

## 1. Purpose

This document defines the architectural contract, data schemas, synchronization protocols, and state machines for the unattended bank transaction extraction pipeline in **Finance Tracker**.

The pipeline ingests notification emails from financial institutions received in Gmail, parses transaction entities using **Gemini 1.5 Flash** with strict structured outputs, stages them asynchronously in **Google Cloud Firestore**, and synchronizes them into the local-first **SQLite** database on the Flutter mobile client without requiring dedicated server infrastructure.

---

## 2. System Architecture & Component Contracts

```
+-----------------------------------------------------------------------------------------+
|                                1. GMAIL & WORKER LAYER                                  |
|                                                                                         |
|  [ Bank Notification Email ] ---> [ Gmail Inbox ]                                       |
|                                         |                                               |
|                                         v (Time-driven trigger: every 5-10 min)         |
|                          [ Google Apps Script Worker ]                                  |
|                                         |                                               |
|                    +--------------------+--------------------+                          |
|                    | Sanitized Text                          | Non-transaction email    |
|                    v                                         v                          |
|        [ Gemini 1.5 Flash API ]                [ Label: FinanceTracker/Ignored ]        |
|        (Strict JSON Output)                                                             |
|                    | Valid transaction                                                  |
|                    v                                                                    |
|  [ Label: FinanceTracker/Processed ]                                                    |
+--------------------+--------------------------------------------------------------------+
                     |
                     v (REST API + Service Account OAuth2)
+-----------------------------------------------------------------------------------------+
|                                2. CLOUD STAGING LAYER                                   |
|                                                                                         |
|  Google Cloud Firestore: `users/{userId}/inbox_transactions/{gmailMessageId}`           |
|  - Status: PENDING -> SYNCED / DISCARDED                                                |
|  - Automatic TTL Cleanup (30 days)                                                      |
+--------------------+--------------------------------------------------------------------+
                     |
                     v (Cloud Firestore SDK / REST on App Launch & Resume)
+-----------------------------------------------------------------------------------------+
|                                3. CLIENT SYNC LAYER                                     |
|                                                                                         |
|  Flutter Mobile Application (Finance Tracker)                                           |
|  - InboxSyncService / AccountMatcher / CategoryMatcher                                  |
|  - Atomic SQLite Transaction (`transactions` + `accounts.balance_cents`)                |
|  - Send ACK to Firestore (`status: SYNCED`, `synced_at: ISO8601`)                       |
+-----------------------------------------------------------------------------------------+
```

---

## 3. Detailed Component Specifications

### 3.1 Worker & Ingestion (Google Apps Script)

#### Gmail Query Contract
To avoid data loss when users read bank emails prior to worker execution, searches rely on persistent Gmail labels rather than read state (`is:unread`):

```javascript
const SEARCH_QUERY = '(from:alertas@banco1.com OR from:notificaciones@banco2.com) ' +
                     '-label:FinanceTracker/Processed -label:FinanceTracker/Ignored ' +
                     'newer_than:2d';
```

#### Preprocessing & Sanitization
1. Extract plaintext via `message.getPlainBody()` or strip HTML markup, CSS blocks, inline scripts, and tracking pixels.
2. Truncate payload to the first 2,000 characters (critical financial metadata is always in the header/first paragraph).
3. Append email headers (`from`, `subject`, `date`) to contextualize parsing.

#### State Transition & Labeling
- If `is_transaction == true`: Write document to Firestore, attach label `FinanceTracker/Processed`.
- If `is_transaction == false`: Attach label `FinanceTracker/Ignored` (prevents reprocessing security/marketing alerts).

---

### 3.2 Structured Extraction Contract (Gemini 1.5 Flash)

The model is invoked with `responseMimeType: "application/json"` and the following strict JSON schema:

```json
{
  "type": "OBJECT",
  "properties": {
    "is_transaction": {
      "type": "BOOLEAN",
      "description": "True if the email denotes an executed financial charge, purchase, withdrawal, deposit, or transfer."
    },
    "bank_name": {
      "type": "STRING",
      "description": "Name of the issuing bank or financial entity (e.g., Bancolombia, Nu, Chase, BBVA)."
    },
    "account_type": {
      "type": "STRING",
      "enum": ["credit_card", "debit_card", "savings", "checking", "cash", "other"],
      "description": "Payment instrument or account type identified in the notification."
    },
    "account_mask": {
      "type": "STRING",
      "description": "Account number mask or last 4 digits (e.g., *1234, Cta 4567, Visa *9876)."
    },
    "merchant": {
      "type": "STRING",
      "description": "Cleaned merchant, business, or recipient name (e.g., Uber Eats, Walmart, Netflix)."
    },
    "amount": {
      "type": "NUMBER",
      "description": "Exact transaction amount in major currency units (e.g., 25.50 or 50000.00)."
    },
    "amount_cents": {
      "type": "INTEGER",
      "description": "Total amount converted to integer cents (e.g., 2550 for 25.50, 5000000 for 50000.00)."
    },
    "currency": {
      "type": "STRING",
      "description": "ISO 4217 standard currency code (e.g., USD, COP, EUR, MXN)."
    },
    "type": {
      "type": "STRING",
      "enum": ["expense", "income", "transfer"],
      "description": "Transaction classification. Outgoing transfers to third parties MUST be classified as 'expense'. Only intra-user transfers are 'transfer'."
    },
    "category_suggestion": {
      "type": "STRING",
      "enum": [
        "Food & Dining",
        "Groceries",
        "Transportation",
        "Housing & Rent",
        "Utilities & Services",
        "Entertainment",
        "Health & Medical",
        "Personal Care",
        "Shopping",
        "Subscriptions & Bills",
        "Other Expenses",
        "Salary & Payroll",
        "Freelance & Business",
        "Investments & Returns",
        "Other Income"
      ],
      "description": "Suggested category conforming to the application default category catalogue."
    },
    "transaction_date": {
      "type": "STRING",
      "description": "ISO 8601 formatted timestamp of the transaction (e.g., 2026-09-12T14:30:00Z)."
    },
    "reference_number": {
      "type": "STRING",
      "description": "Transaction authorization code, approval number, or tracking reference."
    }
  },
  "required": ["is_transaction"]
}
```

---

### 3.3 Cloud Staging Contract (Cloud Firestore)

#### Document Path
`users/{userId}/inbox_transactions/{gmailMessageId}`

#### Document Data Structure
```json
{
  "id": "1914a2c98d72e0f4",
  "bank_name": "Bancolombia",
  "account_type": "credit_card",
  "account_mask": "*4892",
  "merchant": "Supermercados Exito",
  "amount": 125000.00,
  "amount_cents": 12500000,
  "currency": "COP",
  "type": "expense",
  "category_suggestion": "Groceries",
  "transaction_date": "2026-09-12T14:30:00Z",
  "reference_number": "AUT-984712",
  "status": "PENDING",
  "created_at": "2026-09-12T14:35:10Z",
  "synced_at": null,
  "expire_at": "2026-10-12T14:35:10Z"
}
```

#### Lifecycle State Machine
1. **`PENDING`**: Created by Google Apps Script. Awaiting client ingestion.
2. **`SYNCED`**: Read by Flutter client and successfully written to SQLite.
3. **`DISCARDED`**: Manually skipped by user during inbox review.
4. **TTL Deletion**: Documents with `expire_at < NOW()` are purged by Firestore native TTL policy.

---

### 3.4 Client Synchronization & Persistence (Flutter + SQLite)

#### Sync Trigger Triggers
1. **Cold Launch:** Executed during application bootstrap.
2. **App Resume:** Triggered on `AppLifecycleState.resumed`.
3. **User Action:** Pull-to-refresh on transaction list views.

#### Account Resolution Algorithm
1. Query SQLite `accounts` table.
2. Filter accounts where `is_archived = 0`.
3. Evaluate match score:
   - Match by `account_mask` (e.g., account name or description containing digits `4892`).
   - Match by `bank_name` + `account_type` (e.g., `Bancolombia` + `credit_card`).
4. If an exact match is found, bind to that `accountId`.
5. Fallback: If no match is found, bind to the user's primary/default account and flag transaction notes with unmapped account metadata.

#### Category Resolution Algorithm
1. Match `category_suggestion` against SQLite `categories.name`.
2. If found, bind `categoryId`.
3. Fallback: Bind to default fallback category (`cat_default_other_expense` or `cat_default_other_income`).

#### Atomic SQLite Commit
The persistence occurs inside a single database transaction:
```sql
-- 1. Insert Transaction
INSERT INTO transactions (
  id, account_id, to_account_id, category_id,
  amount_cents, original_currency, original_amount_cents, exchange_rate,
  transaction_type, description, transaction_date, created_at, updated_at
) VALUES (
  'tx_gmail_' || :id, :accountId, NULL, :categoryId,
  :amountCents, :currency, :amountCents, 1.0,
  :type, :merchant, :transactionDate, :now, :now
);

-- 2. Update Account Balance
UPDATE accounts
SET balance_cents = CASE 
  WHEN :type = 'expense' THEN balance_cents - :amountCents
  WHEN :type = 'income'  THEN balance_cents + :amountCents
  ELSE balance_cents
END,
updated_at = :now
WHERE id = :accountId;
```

#### Acknowledgment (ACK)
Upon successful commit, Flutter issues a patch to Firestore:
`{ status: "SYNCED", synced_at: ISO8601_TIMESTAMP }`

---

## 4. Invariants

1. **Idempotency Guarantee:** The primary key in Firestore and SQLite is derived deterministically from the Gmail message ID (`gmailMessageId`). Reprocessing an identical email cannot create duplicate database records.
2. **Integer Cents Precision:** Monetary values must never be stored as floating-point numbers in the SQLite database or final domain models. All calculations use integer cents (`amount_cents`).
3. **Foreign Key Integrity:** A transaction must never be inserted without resolving a valid, non-archived `account_id`.
4. **Third-Party Transfer Invariant:** All outgoing transfers to third parties must be persisted with `type = 'expense'`. Only intra-user transfers between two known user accounts may use `type = 'transfer'` with non-null `to_account_id`.
5. **Zero Dedicated Backend Invariant:** The architecture must operate entirely serverless using Google Apps Script triggers, Gemini API, Cloud Firestore, and client-side SQLite.

---

## 5. Concrete Data Flow Example

### Step 1: Incoming Raw Email
- **From:** `alertasynotificaciones@bancolombia.com.co`
- **Subject:** `Bancolombia: Compra con tarjeta`
- **Body:** `Bancolombia le informa compra con tarjeta de credito terminada en 4892 por $125.000,00 en SUPERMERCADOS EXITO el 12/09/2026 14:30. Aprobacion: 984712.`

### Step 2: Gemini Parsed Output
```json
{
  "is_transaction": true,
  "bank_name": "Bancolombia",
  "account_type": "credit_card",
  "account_mask": "*4892",
  "merchant": "Supermercados Exito",
  "amount": 125000.00,
  "amount_cents": 12500000,
  "currency": "COP",
  "type": "expense",
  "category_suggestion": "Groceries",
  "transaction_date": "2026-09-12T14:30:00Z",
  "reference_number": "984712"
}
```

### Step 3: Staged Firestore Document (`users/user_abc/inbox_transactions/1914a2c98d72e0f4`)
```json
{
  "id": "1914a2c98d72e0f4",
  "bank_name": "Bancolombia",
  "account_type": "credit_card",
  "account_mask": "*4892",
  "merchant": "Supermercados Exito",
  "amount_cents": 12500000,
  "currency": "COP",
  "type": "expense",
  "category_suggestion": "Groceries",
  "transaction_date": "2026-09-12T14:30:00Z",
  "reference_number": "984712",
  "status": "PENDING",
  "created_at": "2026-09-12T14:35:10.000Z",
  "synced_at": null,
  "expire_at": "2026-10-12T14:35:10.000Z"
}
```

### Step 4: Resolved SQLite Transaction Row
- **`id`**: `'tx_gmail_1914a2c98d72e0f4'`
- **`account_id`**: `'acc_bancolombia_cc_4892'` (Matched via `Bancolombia` + `credit_card` + `4892`)
- **`category_id`**: `'cat_default_groceries'` (Matched via `'Groceries'`)
- **`amount_cents`**: `12500000`
- **`transaction_type`**: `'expense'`
- **`description`**: `'Supermercados Exito'`
- **`transaction_date`**: `'2026-09-12T14:30:00Z'`

---

## 6. Open Questions & Future Extensions

1. **Multi-Currency Transactions:** If an email is in a currency different from the account's base currency (e.g., USD purchase charged to a COP card with an explicit exchange rate), extend schema with `original_currency` and `exchange_rate`.
2. **Cloud Backup Pipeline Integration:** This Firestore infrastructure serves as the baseline for future full database backups (via Cloud Storage SQLite snapshots or Firestore document synchronization).
