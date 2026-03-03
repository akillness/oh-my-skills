# Role Approval Checklist
<!-- Template: role-approval-checklist.md -->
<!-- Run: {{run_id}} | Tool: {{tool_name}} | Score: {{score}}/100 [{{status_label}}] -->

---

## How to Use This Checklist

Each role reviews only the items relevant to their domain.
Mark each checkpoint before recording your Go/No-Go decision.
A role may choose **Approve**, **Reject**, or **Hold** (pending more information).

Approval chain order: 서비스안정화 → Engineer → PM → CEO (CEO only if P0-cost rules failed)

---

## 서비스안정화 (Service Stability)

> Focus: Failure risk, performance impact, rollback feasibility

**Tool:** {{tool_name}} | **Commit:** {{commit_sha}} | **Env:** {{env}}

**P0 Items Relevant to This Role:**

| Rule ID | Rule Name        | Status | Notes |
|---------|-----------------|--------|-------|
| P0-003  | 롤백 메커니즘    | {{P0-003}} | {{P0-003_detail}} |
| P0-009  | 타임아웃 설정    | {{P0-009}} | {{P0-009_detail}} |
| P0-002  | 에러 핸들링      | {{P0-002}} | {{P0-002_detail}} |
| P0-008  | 로깅 필수 항목   | {{P0-008}} | {{P0-008_detail}} |

**Checkpoints:**

- [ ] 장애 발생 시 롤백 절차가 명확하고 테스트되었다
- [ ] 타임아웃 설정이 현재 SLA 기준에 부합한다
- [ ] 에러 핸들링이 장애 확산을 방지한다
- [ ] 필수 로그가 모니터링 시스템에 연동된다
- [ ] 이 변경으로 인한 성능 영향이 수용 가능한 범위이다

**Decision:**

- [ ] **Approve** — 위 체크포인트 모두 확인. 배포 안정성 승인.
- [ ] **Approve (Conditional)** — 조치 계획 첨부 조건으로 승인. (조치 계획: ________________)
- [ ] **Reject** — 재작업 필요. (사유: ________________)
- [ ] **Hold** — 추가 정보 필요. (요청 사항: ________________)

**Approver:** ________________  **Date:** ________________  **Signature:** ________________

---

## Engineer

> Focus: Root cause of rule failures, technical feasibility of remediation, re-verification

**Tool:** {{tool_name}} | **Commit:** {{commit_sha}}

**All Failed/Warned Rules:**

| Rule ID | Rule Name | Status | File Location | Est. Effort |
|---------|-----------|--------|---------------|-------------|
{{#each failures}}
| {{rule_id}} | {{rule_name}} | {{status}} | `{{file_path}}:{{line_number}}` | {{est_effort}} |
{{/each}}

**Checkpoints:**

- [ ] 모든 P0 실패 항목의 근본 원인을 파악했다
- [ ] 각 실패 항목에 대한 조치 방법이 명확하다
- [ ] 조치 후 재검증 명령어를 실행하여 PASS를 확인했다 (`compliance check --quick`)
- [ ] 조치가 기존 기능에 부작용을 일으키지 않는다
- [ ] P1 경고 항목 중 이번 스프린트에서 처리 가능한 항목을 확인했다

**Re-verification Result:** (재검증 후 기입)

```
compliance check --quick --rules {{failed_rule_ids}}
Result: {{re_verify_score}} / 100  [{{re_verify_status}}]
```

**Decision:**

- [ ] **Approve** — 모든 P0 실패 조치 완료 및 재검증 통과.
- [ ] **Approve (Conditional)** — P1 경고 항목은 다음 스프린트 처리 동의. (항목: ________________)
- [ ] **Reject** — 추가 조치 필요. (미완료 항목: ________________)
- [ ] **Hold** — 기술 검토 추가 필요. (사유: ________________)

**Approver:** ________________  **Date:** ________________  **Signature:** ________________

---

## PM (Product Manager)

> Focus: User impact, schedule options, scope decisions

**Tool:** {{tool_name}} | **Current Score:** {{score}}/100 [{{status_label}}]

**Business Impact Summary:**

| Item              | Detail                           |
|-------------------|----------------------------------|
| 사용자 영향        | {{user_impact_summary}}          |
| 배포 지연 예상     | {{est_delay}}                    |
| P0 실패 건수       | {{p0_fail_count}}건              |
| 조치 예상 공수     | {{total_est_effort}}             |

**Schedule Options:**

- [ ] **Option 1** — 오늘 조치 완료 후 배포 (예상 지연: {{est_delay}})
- [ ] **Option 2** — 핫픽스 배포 후 다음 스프린트 조치 (리스크 수용)
- [ ] **Option 3** — 배포 취소 후 안전 우선 처리

**Checkpoints:**

- [ ] P0 실패 항목이 최종 사용자에게 미치는 영향을 파악했다
- [ ] 일정 조정 또는 범위 변경 여부를 결정했다
- [ ] 스테이크홀더에게 지연 또는 리스크를 통보했다
- [ ] 선택한 일정 옵션을 Engineer/서비스안정화와 합의했다
- [ ] 이 결정이 현재 스프린트 목표와 상충하지 않음을 확인했다

**Chosen Option:** ________________

**Decision:**

- [ ] **Approve** — 일정 및 범위 조정 수용. 배포 진행 동의.
- [ ] **Reject** — 배포 취소. (사유: ________________)
- [ ] **Hold** — 스테이크홀더 확인 필요. (대기 항목: ________________)

**Approver:** ________________  **Date:** ________________  **Signature:** ________________

---

## CEO

> Focus: Cost overrun risk, business-critical failures, final go/no-go
> Required only when: P0-001 (비용 상한 제어) or P0-007 (비용 알림 설정) are FAIL

**Tool:** {{tool_name}} | **Cost Risk:** {{cost_risk_level}}

**Cost-Related Failures:**

| Rule ID | Rule Name     | Status | Risk Description                  |
|---------|---------------|--------|-----------------------------------|
| P0-001  | 비용 상한 제어 | {{P0-001}} | 무제한 비용 발생 가능성 {{P0-001_risk}} |
| P0-007  | 비용 알림 설정 | {{P0-007}} | 비용 폭증 감지 불가 {{P0-007_risk}} |

**Business Risk Summary:**

| Risk Area        | Assessment                   |
|-----------------|------------------------------|
| 비용 초과 가능성  | {{cost_overrun_risk}}        |
| 서비스 다운타임   | {{downtime_risk}}            |
| 사업 연속성       | {{business_continuity_risk}} |

**Checkpoints:**

- [ ] 비용 알림 미설정 시 예상 최대 손실 금액을 확인했다
- [ ] 롤백 불가 시 다운타임으로 인한 사업 영향을 평가했다
- [ ] 위험 수용 시 담당 팀에 책임 범위가 명확히 전달된다
- [ ] 비용 상한 설정 기준(월 $_____)을 재확인했다
- [ ] 이 결정이 현재 사업 우선순위와 일치한다

**Go/No-Go Decision:**

- [ ] **GO** — 위험 수용 및 즉시 배포 승인. (수용 조건: ________________)
- [ ] **NO-GO** — 조치 완료 후 재승인 요구. (필수 조치: ________________)
- [ ] **HOLD** — 추가 리스크 평가 요청. (요청 사항: ________________)

**Approver:** ________________  **Date:** ________________  **Signature:** ________________

---

## Final Deployment Gate Summary

| Role       | Decision | Approver | Timestamp |
|------------|----------|----------|-----------|
| 서비스안정화 | ________ | ________ | ________ |
| Engineer   | ________ | ________ | ________ |
| PM         | ________ | ________ | ________ |
| CEO        | ________ (if required) | ________ | ________ |

**Final Outcome:**
- [ ] All required approvals collected — **DEPLOY APPROVED**
- [ ] One or more rejections — **DEPLOYMENT BLOCKED**
- [ ] One or more holds — **DEPLOYMENT ON HOLD** (resume when resolved)

*Checklist auto-synced to Notion run page: {{notion_page_url}}*
