# 추천 Harness OSS

> 🌐 Language: [English](README.md) | **한국어**

Agent Skills와 함께 사용하기 좋은 오픈소스 에이전트 하네스 및 오케스트레이션 프레임워크 가이드입니다.
GitHub 스타 순으로 정렬되어 있습니다 (2026-03-10 기준).

---

## 비교 테이블

| 레포지토리 | 스타 | 포크 | 설명 | 주요 특장점 |
|-----------|-----:|-----:|------|-------------|
| [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) | 182k | 46.2k | 지속적 에이전트 구축·실행을 위한 접근성 높은 AI 플랫폼 | 플랫폼 수준 에이전트 관리, Forge 툴킷, 노코드 UI, 벤치마크 시스템 |
| [superpowers](https://github.com/obra/superpowers) | 75.7k | 5.9k | 코딩 에이전트를 위한 컴포저블 스킬 프레임워크 & 개발 방법론 | 컴포저블 스킬 정의, TDD 우선, 체계적 워크플로우 계약, 다중 에이전트 호환 |
| [AutoGen](https://github.com/microsoft/autogen) | 55.4k | 8.3k | Microsoft의 멀티 에이전트 대화 및 에이전트 AI 프레임워크 | 계층형 API(Core/AgentChat/Extensions), AutoGen Studio 노코드 UI, MCP 지원 |
| [CrewAI](https://github.com/crewAIInc/crewAI) | 45.7k | 6.1k | 역할극 기반 자율 AI 에이전트 오케스트레이션 프레임워크 | 역할 기반 오케스트레이션, 협업 지능, 독립 Python 프레임워크 |
| [smolagents](https://github.com/huggingface/smolagents) | 25.9k | 2.4k | HuggingFace의 코드 사고 경량 에이전트 라이브러리 | 핵심 ~1,000줄, 모델 불가지론, E2B/Docker 샌드박스, MCP 호환 |
| [agency-agents](https://github.com/msitarzewski/agency-agents) | 21.2k | 3.3k | 9개 부서로 구성된 61개 특화 AI 에이전트 | 폭넓은 전문 에이전트, 부서별 조직화, 플러그앤플레이 역할 정의 |
| [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) | 366 | 94 | Claude Code용 PDCA 방법론 + CTO 주도 에이전트 팀 | PDCA 품질 사이클, 구조화된 게이트, 자동 문서화, Claude Code 네이티브 |

---

## superpowers — 컴포저블 스킬 프레임워크

> **GitHub**: [obra/superpowers](https://github.com/obra/superpowers) · ⭐ 75.7k · 🍴 5.9k

Agent Skills와 철학적으로 가장 유사한 프레임워크. 컴포저블·선언적 스킬 정의를 중심으로 하며, TDD와 체계적인 개발 워크플로우 계약을 강조합니다. Claude Code, Codex CLI 등 여러 코딩 에이전트와 호환됩니다.

### 주요 특장점

| 기능 | 설명 |
|------|------|
| 컴포저블 스킬 | 선언적 스킬 정의 — `SKILL.md` 포맷과 개념적으로 유사 |
| TDD 우선 | 하네스가 구현 전 테스트 작성을 강제 |
| 다중 에이전트 | Claude Code, Codex CLI 등 다양한 코딩 에이전트와 호환 |
| 워크플로우 계약 | 범위 이탈 및 에이전트 드리프트를 방지하는 체계적 계약 |
| 최소 설정 | 관례 우선(convention over configuration) — 즉시 사용 가능 |

### 설치

```bash
git clone https://github.com/obra/superpowers ~/.superpowers
# 레포 README의 setup 안내를 따르세요
```

### Agent Skills와 연동

`superpowers` 스킬 정의를 Agent Skills와 함께 로드할 수 있습니다. `jeo`를 오케스트레이션 레이어로 사용하고 `superpowers` 스킬을 컴포저블 프리미티브로 활용하세요:

```bash
# superpowers 스킬 컨텍스트를 Agent Skills와 함께 로드
jeo "superpowers 스킬 계약을 사용하여 REST API 구현"
```

---

## agency-agents — 61개 전문 에이전트 역할

> **GitHub**: [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) · ⭐ 21.2k · 🍴 3.3k

당신의 손안에 있는 완전한 AI 에이전시. 9개 부서에 걸쳐 61개 특화 AI 에이전트를 제공합니다 — 프론트엔드 위저드, 백엔드 엔지니어부터 커뮤니티 매니저, QA 스페셜리스트까지. 각 에이전트는 명확한 역할, 성격, 업무 범위를 가집니다.

### 부서 맵

| 부서 | 대표 에이전트 |
|------|--------------|
| 프론트엔드 | UI Wizard, Component Architect, CSS Specialist |
| 백엔드 | API Engineer, Database Specialist, Security Auditor |
| DevOps | CI/CD Engineer, Infrastructure Architect, Cloud Specialist |
| QA | Test Engineer, Performance Analyst, Bug Hunter |
| 커뮤니티 | Reddit Ninja, Discord Manager, Content Strategist |
| 프로덕트 | Product Manager, UX Researcher, Analytics Specialist |
| 데이터 | Data Engineer, ML Specialist, Analytics Expert |
| 크리에이티브 | Whimsy Injector, Design Thinker, Brand Voice |
| 메타 | Reality Checker, Devil's Advocate, Synthesizer |

### 주요 특장점

| 기능 | 설명 |
|------|------|
| 61개 에이전트 | 명확한 역할 경계를 가진 고유한 페르소나 |
| 9개 부서 | 체계적인 조직 계층 구조 |
| 플랫폼 불가지론 | 어떤 LLM 플랫폼에서도 바로 사용 가능한 에이전트 정의 |
| 모듈형 | 필요한 에이전트 서브셋만 독립적으로 사용 가능 |
| 즉시 사용 | 사전 정의된 역할 — 추가 설정 불필요 |

### 설치

```bash
git clone https://github.com/msitarzewski/agency-agents
# 에이전트 정의를 에이전트 플랫폼의 스킬/프롬프트 디렉토리에 복사
```

### Agent Skills와 연동

`agency-agents` 역할 정의를 `omc` 팀 멤버의 페르소나 오버레이로 활용하세요:

```bash
# omc 팀 에이전트에 전문 역할 할당
/omc:team "체크아웃 플로우 구현" --persona=frontend-wizard
```

---

## bkit-claude-code — Claude Code를 위한 PDCA 하네스

> **GitHub**: [popup-studio-ai/bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) · ⭐ 366 · 🍴 94

PDCA(Plan-Do-Check-Act) 품질 사이클을 CTO 주도 에이전트 팀과 함께 구현한 Claude Code 플러그인. 각 단계에서 구조화된 게이트와 자동 문서화를 제공합니다.

### PDCA 사이클

```
┌──────────────────────────────────────────────┐
│  PLAN   → 목표 정의, 리스크 평가              │
│  DO     → CTO 주도 에이전트 팀이 실행         │
│  CHECK  → 인수 기준 대비 검증                 │
│  ACT    → 문서화, 회고, 반복                  │
└──────────────────────────────────────────────┘
```

### 주요 특장점

| 기능 | 설명 |
|------|------|
| PDCA 하네스 | 각 단계에서 품질 게이트가 미검증 작업 진행을 방지 |
| CTO 주도 팀 | CTO 에이전트를 오케스트레이터로 하는 계층적 에이전트 조율 |
| 자동 문서화 | 각 PDCA 단계에서 구조화된 문서 자동 생성 |
| Claude Code 네이티브 | Claude Code의 플러그인 시스템에 특화 설계 |
| 단계 추적 | 영속적 상태로 현재 PDCA 단계 관리 |

### 설치

```bash
# Claude Code 대화에서
/plugin marketplace add https://github.com/popup-studio-ai/bkit-claude-code
/plugin install bkit-claude-code
```

### Agent Skills와 연동

`bkit-claude-code`와 Agent Skills는 상호 보완적입니다 — `bmad-orchestrator`로 고수준 단계 게이팅을 하고 `bkit`으로 PDCA 품질 루프를 적용하세요:

```bash
# 예시: bmad 구조 + bkit PDCA 품질 루프
jeo "사용자 인증 구현"  # bmad가 단계 관리, bkit이 품질 검증
```

---

## AutoGPT — 지속적 에이전트 플랫폼

> **GitHub**: [Significant-Gravitas/AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) · ⭐ 182k · 🍴 46.2k

가장 많은 스타를 받은 AI 에이전트 프로젝트. 지속적 AI 에이전트를 구축·배포·모니터링하는 접근성 높은 플랫폼. 최신 버전에는 Forge(에이전트 빌더 툴킷), Benchmark(평가 시스템), 에이전트 관리 UI가 포함됩니다.

### 주요 특장점

| 기능 | 설명 |
|------|------|
| Forge 툴킷 | 표준화된 SDK로 커스텀 에이전트 구축 |
| 벤치마크 | 에이전트 성능 평가를 위한 내장 프레임워크 |
| 노코드 UI | 시각적 에이전트 관리 및 모니터링 대시보드 |
| 플러그인 시스템 | 풍부한 플러그인 생태계를 통한 확장성 |
| 장시간 실행 | 지속적·자율적 멀티스텝 작업 실행에 최적화 |

### 설치

```bash
git clone https://github.com/Significant-Gravitas/AutoGPT
cd AutoGPT
./run setup
```

---

## AutoGen — Microsoft 멀티 에이전트 프레임워크

> **GitHub**: [microsoft/autogen](https://github.com/microsoft/autogen) · ⭐ 55.4k · 🍴 8.3k

Microsoft의 프로덕션급 멀티 에이전트 대화 프레임워크. 단순한 두 에이전트 대화부터 인간 감독이 포함된 복잡한 멀티 에이전트 파이프라인까지 계층형 아키텍처로 지원합니다.

### 주요 특장점

| 기능 | 설명 |
|------|------|
| 계층형 API | Core API(저수준) → AgentChat API → Extensions API |
| AutoGen Studio | 멀티 에이전트 워크플로우 구축·테스트용 노코드 GUI |
| MCP 지원 | Model Context Protocol 네이티브 통합 |
| Magentic-One | 복잡한 웹/코드 작업을 위한 사전 구축된 멀티 에이전트 팀 |
| Human-in-the-loop | 인간 감독 체크포인트 일급 지원 |

### 설치

```bash
pip install pyautogen
# 또는 최신 기능 포함:
pip install "pyautogen[all]"
```

---

## CrewAI — 역할 기반 에이전트 오케스트레이션

> **GitHub**: [crewAIInc/crewAI](https://github.com/crewAIInc/crewAI) · ⭐ 45.7k · 🍴 6.1k

역할극 기반 자율 AI 에이전트 오케스트레이션 프레임워크. 각 에이전트는 역할, 목표, 배경 스토리를 가지며 순차적 또는 병렬로 협력하여 복잡한 작업을 완수합니다.

### 주요 특장점

| 기능 | 설명 |
|------|------|
| 역할 기반 설계 | 각 에이전트에 역할, 목표, 배경 스토리 정의 |
| 협업 | 에이전트들이 출력을 공유하고 서로의 작업 위에 구축 |
| 독립적 | LangChain 비의존 독립 Python 프레임워크 |
| 고수준 API | 간단한 crew + agent + task 정의로 시작 |
| 유연한 실행 | 순차적, 병렬, 계층적 프로세스 실행 지원 |

### 설치

```bash
pip install crewai
# 툴 지원 포함:
pip install crewai crewai-tools
```

---

## smolagents — 코드 사고 경량 에이전트

> **GitHub**: [huggingface/smolagents](https://github.com/huggingface/smolagents) · ⭐ 25.9k · 🍴 2.4k

HuggingFace의 "코드로 사고하는" 경량 에이전트 라이브러리. 전체 핵심 로직이 ~1,000줄이라 감사(audit)가 쉽고 이해하기 쉽습니다. HuggingFace Hub 또는 API를 통한 어떤 모델도 지원합니다.

### 주요 특장점

| 기능 | 설명 |
|------|------|
| 코드 사고 | 에이전트가 JSON이 아닌 Python 코드로 추론·행동 |
| 최소 풋프린트 | ~1,000줄 코어 — 완전히 감사 가능 |
| 모델 불가지론 | HuggingFace Hub 모델, OpenAI, Anthropic 등 모두 지원 |
| 샌드박스 실행 | 안전한 코드 실행을 위한 E2B 및 Docker 샌드박싱 |
| MCP 호환 | MCP 서버 및 LangChain 툴 네이티브 지원 |

### 설치

```bash
pip install smolagents
# 모든 선택적 의존성 포함:
pip install "smolagents[all]"
```

---

## 관련 링크

| 리소스 | 링크 |
|--------|------|
| Agent Skills 메인 문서 | [../../README.ko.md](../../README.ko.md) |
| omc — Claude Code 멀티 에이전트 오케스트레이션 | [../omc/README.md](../omc/README.md) |
| ralph — 스펙 우선 개발 루프 | [../ralph/README.md](../ralph/README.md) |
| jeo — 통합 오케스트레이션 스킬 | [../../.agent-skills/jeo/SKILL.md](../../.agent-skills/jeo/SKILL.md) |
| bmad-orchestrator — 단계 기반 개발 | [../bmad/README.md](../bmad/README.md) |
