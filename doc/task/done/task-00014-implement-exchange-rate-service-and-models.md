---
id: task-00014-implement-exchange-rate-service-and-models
type: task
code: "00014"
slug: implement-exchange-rate-service-and-models
title: Implement Exchange Rate Service and Models
description: Create the ExchangeRate model and lightweight HTTP service client for open.er-api.com with error handling and unit tests.
status: done
created: 2026-09-06
updated: 2026-09-06
tags:
  - exchange-rate
  - http
  - api
  - service
related:
  - plan-00003-multi-currency-transactions-plan
  - rfc-00003-multi-currency-transactions-exchange-rates
supersedes: []
superseded_by: null
---

# Task 00014: Implement Exchange Rate Service and Models

## 1. Prime Directive

> [!Prime Directive]
> Implement a reliable, testable HTTP client for `open.er-api.com` that fetches live currency conversion rates and parses them into a strongly typed `ExchangeRateResult` entity with timeout and error resilience.

## 2. Specs

- **Module:** `ui/lib/core/services`, `ui/lib/domain/entities`
- **Dependencies:** `package:http`

## 3. Checklist

### 3.1. Phase A — Domain Entity and Service Implementation

- [x] Create `ExchangeRateResult` entity in `lib/domain/entities/exchange_rate_result.dart` holding `baseCode`, `rates` (`Map<String, double>`), `lastUpdatedUtc`, and `nextUpdateUtc`.
- [x] Create `ExchangeRateService` in `lib/core/services/exchange_rate_service.dart` consuming `https://open.er-api.com/v6/latest/{baseCurrency}`.
- [x] Implement timeout (10 seconds), status code validation, and graceful exception handling returning structured `Result` or `null`.

### 3.2. Phase B — Unit Testing & Quality Gate

- [x] Create `test/unit/core/services/exchange_rate_service_test.dart` testing successful JSON parsing, network timeouts, and HTTP error responses.
- [x] Ensure all tests pass and static analysis is clean.

