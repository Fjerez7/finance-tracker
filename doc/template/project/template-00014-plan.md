---
id: plan-<code>-<slug>
type: plan
code: "<code>"
slug: <slug>
title: <Title>
description: <One sentence describing what this plan defines and the bounded scope it covers.>
category: plan
status: draft
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
authors: []
tags: []
related: []
supersedes: []
superseded_by: null
aliases:
  - "PLAN <code>: <Title>"
---

# PLAN <CODE>: <Title>

## 1. Purpose

<One or two paragraphs describing what this plan defines and why it exists. State the bounded goal and the design scope. Identify any prerequisite specs or RFCs that must be read first.>

This plan is phase-based. Phases that introduce architectural decisions or technical uncertainty produce an RFC before implementation; straightforward implementation phases proceed directly to Tasks.

---

## 2. Design Prerequisites (optional)

<If this plan depends on components that must be designed before the implementation pipeline phases, describe them here. Each component gets its own subsection. Omit this section entirely if there are no design-order constraints.>

### 2.1 — <Component Name>

**RFC:** [[<rfc-id>]] — <Status>  
**Module:** `<module>`

<Describe the component's role, key invariants, and why it must be fully specified before the phases that depend on it.>

---

## 3. Implementation Phases

Phases are listed in design and delivery order. Each phase has a bounded responsibility. Phases involving architectural tradeoffs should produce an RFC; standard implementation phases can define Tasks directly.

### Phase 1 — <Phase Name>

```vector-agent-inline-action
label: Create an RFC
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: derive it from Phase 1 - <Phase Name>
  document-type: rfc
```

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: derive it from Phase 1 - <Phase Name>
  document-type: task
```

**Goal:** <Single sentence stating what this phase delivers.>

**RFC:** [[<rfc-id>]] <!-- Optional: link RFC if an architectural decision was required for this phase -->
**Tasks:**
- [[<task-id>]]

**Input:** <What enters this phase>  
**Output:** <What this phase produces>

<Bullet points describing the bounded scope of this phase. Design intent only — no implementation detail.>

- <Responsibility 1>
- <Responsibility 2>
- <Responsibility 3>

### Phase 2 — <Phase Name>

```vector-agent-inline-action
label: Create an RFC
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: derive it from Phase 2 - <Phase Name>
  document-type: rfc
```

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: derive it from Phase 2 - <Phase Name>
  document-type: task
```

**Goal:** <Single sentence.>

**RFC:** [[<rfc-id>]] <!-- Optional -->
**Tasks:**
- [[<task-id>]]

**Input:** <Input>  
**Output:** <Output>

- <Responsibility 1>
- <Responsibility 2>

### Phase N — <Phase Name>

```vector-agent-inline-action
label: Create an RFC
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: derive it from Phase N - <Phase Name>
  document-type: rfc
```

```vector-agent-inline-action
label: Create a Task
prompt-field: message
profile: create-doc
prompt: prompts-00005-create-document
input:
  document-name: derive it from Phase N - <Phase Name>
  document-type: task
```

**Goal:** <Single sentence.>

**RFC:** [[<rfc-id>]] <!-- Optional -->
**Tasks:**
- [[<task-id>]]

**Input:** <Input>  
**Output:** <Output>

- <Responsibility 1>
- <Responsibility 2>

---

## 4. Invariants

<Non-negotiable rules that apply across all phases. These are constraints, not goals. Phrase each as a hard rule.>

- <Invariant 1>
- <Invariant 2>
- <Invariant 3>

---

## 5. Examples (optional)

<Short command-line, API, or usage examples that ground the plan in concrete behavior. Omit if the plan has no user-facing surface.>

```text
<example invocation or usage>
```

---

## 6. Staff Engineer Review

### On the Overall Plan

**Gaps that still need RFC coverage:**

1. <Gap 1>
2. <Gap 2>

**Flaws to watch:**

- <Flaw or risk 1>
- <Flaw or risk 2>

**Tradeoffs accepted by this plan:**

- <Tradeoff 1>
- <Tradeoff 2>

---

## 7. Open Questions

- <Question 1>
- <Question 2>
- <Question 3>