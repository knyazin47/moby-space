# Family space v2 API

Synthetic BYN minor units only. Existing API and child `balanceMinor` remain; this balance excludes goals and earmarked errand budgets. `POST /v1/family-space/commands` returns a current full, role-scoped `Snapshot` (HTTP 200). Every command requires `type`, `childId`, `idempotencyKey` (8–80 chars). Same actor/key + same JSON semantic fields retries without duplicate effects; changed command returns 409. Child can address only itself. All money commands require an active, verified, signed synthetic child product. Errors `{error:code}`; 400 invalid input, 401 unauthenticated, 403 wrong actor, 404 missing/scoped entity, 409 unavailable funds/state.

Snapshot adds `familySpace`:

- `adultWallet`: **adult only** `{availableMinor,reservedMinor,currency:"BYN"}`. One finite synthetic opening endowment of 100000 minor is recorded by migration once. Old child balances stay unchanged. No mint endpoint.
- `goals`: `{id,childId,title,targetMinor,savedMinor,matchedMinor,netDepositsMinor,matchedBasisMinor,matchingAvailableMinor,matchingStatus}`. Matching cap is lifetime per goal; deposits before enabling are excluded; withdrawal/redeposit cannot multiply rewards, including recycling withdrawn matching credits. `netDepositsMinor` remains a nonnegative display value, derived as max(0, savedMinor - lifetime matchedMinor); eligibility uses the signed conserved position savedMinor - lifetime matchedMinor - matchedBasisMinor. Thus withdrawn reward debt survives empty goals and restarts without exposing a negative field. `matchingStatus` is available/not_eligible/awaiting_funds, without revealing adult amount.
- `tasks`: `{id,childId,title,rewardMinor,status,cancelRequested,cancelReason?}`.
- `errands`: `{id,childId,title,budgetMinor,rewardMinor,actualMinor,returnedMinor,funding,status,ownMoneyConsent,cancelRequested,returnConfirmed,expenseRecorded,rewardReserved,cancelReason?}`. Earmarked budget is independent from purchase balance.
- `allowances`: `{id,childId,title,amountMinor,frequency,weekdays,monthDay,nextDate,retryLimit,active}`. Weekday 0 Sunday through 6 Saturday.
- `installments`: `{id,childId,allowanceId,dueDate,amountMinor,status,attempts,lastAttemptDate?,retryLimit?}`. Installment retryLimit is frozen when created and does not inherit later schedule edits.
- `requests`: `{id,childId,title,kind,policy?,amountMinor?,status}`.
- `settings`: map child ID → `{matchingEnabled,matchingPercent,matchingCapMinor,notifications,tasksEnabled,errandsEnabled,learningEnabled}`. Defaults false/0/0/true/true/true/true.
- `learning`: `{childId,lessonId,completedAt}`; `lessons`: fixed `{id,title,body,skill,question,options}` catalogue; correct answers are never returned. No score, streak or automatic rights.
- `activity`: newest 200 scoped family ledger events `{id,childId?,kind,amountMinor,at,entityId?}` sorted descending at then id. Filtering occurs before limiting. Opening endowment is adult-only. No command keys/fingerprints/session metadata; legacy operations stay in the existing operations array and are not duplicated here.
- `weekly`: `{childId,since,incomingMinor,spentMinor,savedMinor,tasksCompleted,lessonsCompleted}` derived last seven Minsk calendar dates. Income/spending from completed ledger entries; goals tracked separately.

Immutable `capabilities`: `{synthetic:true,currency:"BYN",timeZone:"Europe/Minsk",maxAmountMinor:10000000,matchingCapPeriod:"goal_lifetime",lessonsGrantPermissions:false}`. Notifications settings suppress routine in-app notices; required decisions and financial confirmations remain visible. No OS push.

All arrays/settings are filtered to current child for child sessions; siblings and adult funds are absent. Existing adult preferences remain adult-only. All fields above use JSON numbers for integers, UTC epoch seconds for timestamps, YYYY-MM-DD for Minsk calendar dates.

Commands (extra optional fields omitted):

| type | Actor | Fields/actions |
|---|---|---|
| `card.block` | child/adult scoped | Sets own child synthetic active/blocked card to blocked immediately; no XP/settings/identity verification gate. None/unopened rejects 409. Idempotent replay, mandatory notice. Unblock remains adult-only existing PATCH with verified/signed product guards. |
| `wallet.transfer` | adult | `amountMinor` transfers finite available adult balance into child available balance; creates existing `topup` ledger entry |
| `notice.read` | matching recipient | `entityId` notice ID; actor can mark only its own recipient inbox records |
| `goal.create` | child | `title,targetMinor` >0 |
| `goal.move` | child | `entityId,amountMinor,action:"deposit" / "withdraw"` |
| `goal.match` | adult | `entityId,amountMinor`; explicit opt-in settings, capped contribution and available adult balance |
| `task.create` | adult | `title,rewardMinor` >0; offered, no hold yet |
| `task.action` | child | `entityId,action:"accept"` atomically reserves adult reward; `submit`; `dispute`; `agree_cancel` only after adult request |
| `task.action` | adult | `entityId,action:"approve"` submitted → paid once; `clarify`; `cancel,reason` any unpaid state, required reason 1–240 chars visible in cancelReason and inbox; `request_cancel` remains compatible |
| `errand.create` | adult | `title,budgetMinor,rewardMinor,funding:"funded" / "awaiting_funds" / "reimburse"`; reward >=0; funded reserves budget+reward |
| `errand.action` | adult | `entityId,action:"fund"` awaiting funds → funded; `approve` submitted → settles spent budget/reimbursement+reward once; `clarify`; `cancel,reason` unpaid zero-expense states only, requires reason 1–240 chars; `request_cancel` |
| `errand.action` | child | `accept` (reimburse additionally requires `ownMoneyConsent:true`); `submit,amountMinor` actual <=budget, own-money spend debited from available once; `return` explicitly confirms remaining earmark; `dispute`; `agree_cancel` |
| `allowance.create` | adult | `title,amountMinor,frequency:"daily"/"weekly"/"monthly",weekdays:[0..6]` (weekly nonempty), `monthDay:1..31` (monthly), `nextDate` today/future, `retryLimit:0..3` opt-in daily retries |
| `allowance.update` | adult | `entityId` and full same validated fields as create; nextDate must be today/future and is adjusted to first matching calendar date. Preserves id, childId and active/paused state. Existing installment amounts, dates, status and frozen retry policy stay untouched; no immediate or backlog payment. |
| `allowance.action` | adult | `entityId,action:"pause"/"resume"` schedule; `entityId,action:"settle"/"cancel"` pending insufficient/missed installment |
| `settings.update` | adult | full `settings` object, percent 0..100, cap >=0 |
| `request.create` | child | `title,kind:"policy"/"help"/"money",policy?,amountMinor?` full valid existing Policy required for policy request; money requires >0 amount |
| `request.decide` | adult | `entityId,approve:true/false`; approval applies exactly proposed policy or transfers requested amount from finite adult funds once; no learning gates |
| `lesson.complete` | child | `answerIndex` required, wrong answer 400 `wrong_answer` with no completion; `entityId` fixed lesson ID: needs-wants / saving-goal / safe-payment / budget |

Task states offered → accepted → submitted → approved; clarification/disputed retain hold; child resubmits clarification/disputed. Canceled is terminal. Rewards never editable. Adult can cancel any unpaid task with a required visible reason and release its hold once; paid money stays untouched. Child-agreed cancellation remains compatible. Errand states follow task states, with funding tracked separately; awaiting_funds cannot be accepted. Reimbursement never debits a child without explicit consent. Its optional reward is reserved atomically at child acceptance, or acceptance fails with insufficient_adult_balance. Actual expense compensation remains a visible unfunded obligation until adult settlement. Reimbursement approval debits actual expense from adult available plus reward from reserved; recorded positive expenses cannot be canceled. Remainders are returned only from current earmark, never from unrelated child funds. Approval requires explicit child return confirmation when a funded errand has remainder.

Schedules run in Go ticker, persisted atomically. Due installments keyed schedule+date. Every overdue occurrence is persisted as missed, never automatic catchup. A due batch with insufficient total funds is marked insufficient as a whole, without sibling priority. Retry limit opt-in bounded daily attempts within due date + retryLimit days; canceled/missed never automatically retried; adult may settle explicitly. Monthly day 29–31 clamps to last calendar day. Schedule resume advances to today/future and does not replay paused dates.

## In-app inbox

`familySpace.notices` contains only the current actor recipient's records: `{id,childId,recipient,title,body,kind,createdAt,read,mandatory}`. Adult records cover its children; child records cover only itself. `notice.read` checks both child ownership and recipient role and is idempotent. Notices contain no adult balance, sibling names, session data or credentials. Routine offers/goal activity/lesson progress respect per-child notifications preference; financial confirmations, cancellations and requested decisions cannot be suppressed. Scheduler emits paid/missed/insufficient notices. Retention is the latest 2000 family records, a system-owned bounded demo inbox setting. No delivery through OS push is implemented.

## Archive and legacy guards

`POST /v1/children/{id}/archive` fails with 409 `pending_family_obligations` before changing membership, sessions, pairing or revision if this child has a nonzero goal, accepted/submitted/clarification/disputed task hold, unsettled funded errand, reserved reimbursement reward, or an incurred positive expense awaiting compensation. Withdraw goal funds or explicitly settle/cancel the relevant work first; no destructive cleanup, forfeiture or silent release occurs. Completed/canceled work and zero goals do not prevent archival. Legacy `topups` and v2 transfers both require currently verified identity, a signed synthetic agreement and an open synthetic account before a new debit; a rejected verification cannot receive a new legacy credit.

Protective administration is deliberately separate from money transfer checks: an adult may cancel an unpaid task, cancel an errand without any incurred expense, or pause an allowance even if current child verification became rejected/pending. These commands transfer no money to a child; they release only the existing adult reserve or stop future attempts. Cancellation still requires the visible reason, terminal state guard and zero-expense errand guard. Other money commands and allowance resume/settle retain current verified/signed product checks.

Allowance update is atomic and does not mutate any existing installment. An update pointing to an already paid/insufficient date cannot replace that dated occurrence or pay it again; only subsequent new occurrences use the new amount and retry limit. Existing pre-freeze v2 installments receive their previous schedule's retry limit once on startup, before any edit can change it.
