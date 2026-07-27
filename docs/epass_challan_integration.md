# E-Pass Challan Integration

Mineral transport challans (e-Pass) issued by state government mining portals are
captured into LedgerPro as project material entries.

**Supported portals** — the user picks one from a "State portal" dropdown in
step 1, and the flow then talks only to that portal:

| State | Host | `source_portal` |
|-------|------|-----------------|
| Bihar (Khanan Soft) | `khanansoft.bihar.gov.in` | `bihar_khanan_soft` |
| Jharkhand (Minerals Portal) | `mineralsportal.jharkhand.gov.in` | `jharkhand_minerals_portal` |
| Madhya Pradesh (e-Khanij eTP) | `ekhanij.mp.gov.in` | `mp_ekhanij_etp` |

`source_portal` is the first component of the duplicate uniqueness key, so the
same challan number can exist once per state without colliding. Adding a portal
needs **no migration**: the column is free text.

The module lives in `lib/features/challans/` and is self-contained: it reuses the
app's existing theme, components, Riverpod conventions, permission model and
Supabase repository style, and adds no second design system.

---

## 1. Architecture

```
lib/features/challans/
├── application/
│   ├── challan_flow_controller.dart   Orchestrates the 5 steps
│   ├── challan_flow_state.dart        Freezed state + ChallanFlowStep
│   └── challan_providers.dart         Riverpod providers
├── data/
│   ├── challan_repository.dart        Supabase reads (PostgREST) + writes (RPC)
│   ├── challan_portal_adapter.dart    Adapter interface + platform/nav policy
│   ├── epass_portal_adapter.dart      Portal-parameterised implementation
│   └── challan_dom_parser.dart        3-layer resilient DOM extraction
├── domain/
│   ├── challan_models.dart            Freezed models
│   ├── challan_portal.dart            Supported portals + their differences
│   ├── challan_status.dart            Verification status + method
│   ├── material_type.dart             Materials + financial-year helpers
│   └── challan_exceptions.dart        Error taxonomy
└── presentation/
    ├── challan_screen.dart            Adaptive host (mobile/tablet/desktop)
    ├── challan_portal_screen.dart     Government portal WebView
    ├── challan_detail_screen.dart     Read-only saved record
    └── widgets/…                      Step widgets, list, card, dialogs
```

Layering rule: portal parsing never happens in a widget. The WebView screen's
only job is to hand raw markup to the adapter; the adapter delegates to the
parser; the controller decides what the user sees.

### Data flow

```
User → MaterialSelectionStep → ChallanFlowController.continueFromSelection()
                                        ↓ (duplicate pre-check)
     → ChallanPortalScreen (WebView)  ← user completes CAPTCHA + presses Search
                                        ↓ readResultHtml()
     → BiharEPassWebViewAdapter.capture() → ChallanDomParser.parse()
                                        ↓ ChallanCaptureResult
     → ChallanPreviewStep (read-only)  → ChallanRepository.createCapturedChallan()
                                        ↓
     → RPC create_epass_challan()  → validate + normalize + dedupe + insert + audit
```

---

## 2. The five-step flow

| Step | Screen | What happens |
|------|--------|--------------|
| 1. Project & Material | `material_selection_step.dart` | Project (mandatory), material, financial year, challan number. Runs a duplicate pre-check so the user is not sent through a CAPTCHA for a challan that already exists. |
| 2. Government Portal | `government_portal_step.dart` → `challan_portal_screen.dart` | Portal opens in the in-app WebView. Financial year and challan number are prefilled. |
| 3. Challan Verification | `challan_verification_step.dart` | The user completes CAPTCHA and presses the portal's Search. LedgerPro then reads the result and validates it. |
| 4. Auto Fetch & Preview | `challan_preview_step.dart` | Read-only preview of every captured field, plus capture status and timestamp. |
| 5. Save Entry | `challan_save_step.dart` | Atomic RPC save with server-side duplicate check and audit log. |

### Input normalization

| Value | Stored as | Comparison key |
|-------|-----------|----------------|
| Challan number | Exactly as typed, trimmed, Latin letters upper-cased (`BR-2026/001`) | `normalized_challan_number` — `[A-Z0-9]` only (`BR2026001`) |
| Vehicle number | As shown by the portal, upper-cased (`BR 01 GH 4567`) | `normalized_vehicle_number` (`BR01GH4567`) |

Normalization runs **three** times on purpose: in Dart for instant feedback, in
the RPC, and in a `BEFORE INSERT OR UPDATE` trigger so a direct PostgREST write
cannot bypass the duplicate index.

### Financial year

Derived from the clock, never hard-coded. Years run 1 April → 31 March and are
formatted `2026-2027`. `FinancialYear.options()` returns 5 years back and 1 ahead
of the current FY; the exact selected string is preserved on the record.

---

## 3. CAPTCHA and the human-verification limitation

**This is the defining constraint of the module.**

LedgerPro does **not** and **will not**:

- solve, bypass, automate, intercept or outsource CAPTCHA
- run OCR against a CAPTCHA image
- send a CAPTCHA image to any third party
- auto-submit credentials or auto-press the portal's Search button
- store government usernames, passwords or CAPTCHA values

The portal is opened in a WebView the **user** drives. They complete CAPTCHA and
login themselves and press the portal's own Search button. Only once the result
is rendered does LedgerPro read it.

### Why the terminology matters

Because the data comes from a user-controlled browser session, it is **not**
equivalent to data signed off by an authorized government API. The status
vocabulary makes that distinction explicit and never collapses to a bare
"verified":

| Status | Meaning | UI label |
|--------|---------|----------|
| `portal_captured` | Read from the portal's rendered result after the user completed human verification | **"Captured from Bihar Government Portal"** |
| `manual_unverified` | Typed or corrected by a human | "Manual (unverified)" |
| `official_api_verified` | **Reserved.** A future authorized government API only | "Official API Verified" |
| `invalid` | Portal reported the challan as invalid | "Invalid" |
| `expired` | Validity window passed | "Expired" |

| Method | Meaning |
|--------|---------|
| `webview_human_verification` | In-app WebView, human completed verification |
| `manual_entry` | Manual data entry |
| `official_api` | Reserved; **the RPC currently rejects it** |

`create_epass_challan` raises if `p_verification_method = 'official_api'`, so the
reserved status cannot be written before that integration genuinely exists.

### Prefill safety

The injected prefill script skips any field whose id or name contains `captcha`,
`capcha`, `password`, `pwd`, `otp`, or whose type is `password`. It dispatches
`input` and `change` events (required by ASP.NET WebForms validation), leaves the
values editable, and never submits the form.

---

## 4. WebView security model

Implemented in `challan_portal_screen.dart` and `challan_portal_adapter.dart`.

| Control | Implementation |
|---------|----------------|
| Host allow-list | `PortalNavigationPolicy` permits only HTTPS on `khanansoft.bihar.gov.in` and its subdomains. Suffix look-alikes such as `khanansoft.bihar.gov.in.evil.com` are rejected. |
| External links | Anything outside the allow-list is handed to the OS browser via `NavigationDecision.prevent` + `launchUrl`. |
| TLS | `onSslAuthError` calls `error.cancel()` — invalid certificates are **never** accepted. The user sees a blocking warning telling them not to enter credentials. |
| File access | Never enabled. `file://` navigation fails the allow-list. |
| JS bridge | No `addJavaScriptChannel` anywhere. There is no generic bridge. |
| Extraction command | Exactly one capability: return the result region's markup, with `script`, `style`, `noscript`, `img`, `iframe`, `input[type=password]` and `input[type=hidden]` stripped first — so the CAPTCHA image and hidden state never leave the page. |
| Logging | No cookies, credentials, CAPTCHA values or page HTML are logged. Adapter failures deliberately discard the underlying error because it can embed page content. |
| Credential storage | None. Nothing from the portal session is persisted. |
| Domain visibility | The live host is displayed prominently above the WebView (anti-phishing), alongside the mandated notice. |
| Session controls | Refresh portal · Open externally · Clear portal session (clears cookies, cache, local storage) · Back to LedgerPro · Capture displayed details. |

Displayed notice:

> You are viewing the Bihar Government portal. Complete CAPTCHA or login
> manually. LedgerPro never stores your government credentials.

---

## 5. Portal parsing strategy

`ChallanDomParser` runs three independent layers. Each fills only the fields the
previous layers left empty, so no single selector is load-bearing.

**Layer 1 — element ids.** Matches ids/names whose normalized *suffix* equals a
known ASP.NET label control (`lblchallanno`, `lblvehicleno`, …). Suffix matching
survives master-page prefix churn like `ctl00_ContentPlaceHolder1_` →
`ctl99_MainContent_`.

**Layer 2 — labelled containers.** Table rows (tolerating a `:` separator cell
and several pairs per row), definition lists, and leaf label elements followed by
a value element. Container elements are skipped so a wrapper `<div>` is never
mistaken for a label.

**Layer 3 — visible text.** `Label : Value` pairs recovered from the page text,
supporting multiple pairs per line.

Deliberately **not** used: nth-child selectors, CSS position, colour, visual
location, or a single generated control id.

### Recognized labels (English + Hindi)

`Challan No.` / `चालान नंबर` · `UID No.` / `यूआईडी नंबर` · `Challan Date` /
`चालान की तिथि` · `Challan Validity` / `चालान की वैधता` · `Consignor Name` /
`कंसाइनर का नाम` · `Challan Generate from` · `Location` / `स्थान` ·
`Destination` / `गंतव्य` · `Vehicle Type` / `वाहन का प्रकार` · `Vehicle No.` /
`वाहन नंबर` · `Mineral Name` / `खनिज का नाम` · `Quantity` / `मात्रा` ·
`Consignee Name` / `प्राप्तकर्ता का नाम` · `Royalty Amount`

Label matching folds case, whitespace, punctuation and `number` → `no`, then
prefers the longest match so `vehicle number` wins over `vehicle`.

### Value normalization

| Field | Rule |
|-------|------|
| Dates | `dd/MM/yyyy`, `dd-MM-yyyy`, `dd.MM.yyyy`, `yyyy-MM-dd`, optional `HH:mm[:ss]` and AM/PM. Parsed as **IST (UTC+05:30)** and returned as UTC, so the date is correct for users outside India. Invalid dates return null. |
| Quantity | Kept as the exact decimal **string** (`quantityText`) and sent to `numeric(14,3)` as a string, so no binary-float rounding ever reaches the database. A `double` is derived for display/validation only. |
| Quantity unit | Stored **only when the portal printed one**. When absent, the record saves `MT` and `portal_payload.quantity_unit_source = 'assumed_mt'`, and the preview says "unit not shown by portal — saved as MT". |
| Royalty | Rupee text → integer paise using string math, never `double`. |
| Empty strings | Converted to `null`. |
| Names / locations | Repeated whitespace collapsed. |
| HTML entities | Decoded, including numeric entities and `&nbsp;`. |
| Unknown portal fields | Preserved verbatim in `portal_payload.fields` so a later release can backfill without re-capturing. |

### Validation before a capture is accepted

Mandatory: challan number, challan date, vehicle number, mineral name, quantity.
Recommended (stored when present): UID, validity, consignor, generated from,
source, destination, vehicle type, consignee, royalty.

A capture is accepted only if **all** of these hold:

1. The page is not a "no record found" banner.
2. All five mandatory fields are present.
3. The returned challan number matches the entered one (normalized).
4. The challan date falls inside the selected financial year (skipped when the
   portal shows no date).

Otherwise the user gets an actionable error and **nothing is saved**:

| Situation | Error |
|-----------|-------|
| No fields found, no result section | "Complete the CAPTCHA … then capture" |
| No-record banner | "The portal reported no record for this challan number" |
| Challan number missing, or ≥3 mandatory fields missing | **"Portal layout changed"** |
| 1–2 mandatory fields missing | "The portal result is missing …" |
| Different challan returned | "The portal returned challan X, but you entered Y" |
| Wrong financial year | "…does not belong to the selected financial year" |

### Per-portal differences (verified against the live pages)

Everything portal-specific is declared in `ChallanPortal`, so the flow, WebView
screen and parser stay portal-agnostic.

| | Bihar | Jharkhand | Madhya Pradesh |
|---|---|---|---|
| CAPTCHA on the page | none | **yes** (`imgCaptcha` / `txtCaptcha`) | **yes** (`txtCaptcha` + `captcha.aspx`) |
| Financial-year selector | `ddlfinancialyear` | **none** (prefill skips it) | **none** (prefill skips it) |
| Result layout | `<table>` label/value rows | **Bootstrap grid** (label and value in *sibling containers*) | **GridView** (header row + data row, no ids on any cell) |
| Challan input | `txtchallanno` | `txtPassNo` | `txtetp` (numeric, `maxlength=10`) |
| Search mode | shown immediately | shown immediately | **`rbsearchtype` radio must be picked first** |
| Submit button | "Search" | "Search" | "Verify" |
| Identifier label | "Challan No." | "Pass No." | "eTP NO." |
| Secondary id | `lblUIDNo` ("UID No.") | `lblPermitNo` ("Permit No.") | "Lease No." column |
| Validity | `lblChallanValidity` | `lblPassValidity` | not shown on the grid |
| Quantity unit | separate `lblunit` | none (unit is inside the quantity text) | **no unit column** (falls back to the stored default) |
| Vehicle type | `lblVehicleType` | absent | absent |
| Consignee | `lblconsigneename` | absent | absent |
| `NA` placeholders before search | yes | yes | **no** (nothing renders at all) |
| Renders usably at phone width | yes | yes | **no** — collapses to a mobile theme |

Three consequences worth knowing:

- **The element-id map must be per portal.** On Jharkhand the *Consigner Name*
  value is rendered by a span called **`lblconsigneename`** — the same id that on
  Bihar genuinely means the consignee. A shared map would silently file a
  consignor as a consignee, so `ChallanDomParser` takes a `portal` and selects
  the matching id map. Labels (layers 2 and 3) remain shared, since the label
  *text* is unambiguous on both.
- **Layer 2 gained an ancestor walk** to handle Jharkhand's grid, where the label
  is not a sibling of its value. It only walks up while the ancestor contains
  nothing but the label text, so a wrapper holding both is never treated as a
  label.
- **A grid layer (`_layerGridColumns`) reads column-oriented results** for MP,
  which renders its verified eTP into a `GridView`: a header row of column names
  followed by the data row. No label/value layer can read that shape, so this
  layer pairs by column index. A column counts when its header **resolves to a
  field**, not only when it is an exact label — MP's real headers are phrases
  ("Date & Time of Transportation", "Destination Station", "Mineral Qty") and an
  exact-label gate matched only three of its ten columns. Three guards keep it off
  the vertical layouts: the header row must resolve **three distinct fields**
  (a Bihar or Jharkhand row holds one label plus its value, so it cannot
  qualify), no resolving header cell may contain a digit, and only the first data
  row carrying values is read. Tables the grid layer consumes are excluded from
  layer 2, so a grid is never also mis-read as label/value rows.

Jharkhand's "Permit No." is stored in `uid_number` (the portal's identifier
column); the original label is preserved in `portal_payload.fields`.

Neither Jharkhand nor MP has a financial-year field, so there the financial year
is purely LedgerPro's own bookkeeping — it is still recorded and still forms part
of the duplicate key.

### Madhya Pradesh

Both sides are now verified against the live `Verify_eTP.aspx` page.

**Form.** Pinned by `PortalFixtures.mpEtpFormMarkup`: the `rbsearchtype` radio
group (value `1` = eTP No, `2` = Vehicle No), the numeric `txtetp` input, the
`txtCaptcha` box, the "Verify" button and the empty `pnlgridvehicle` panel. On
the first load **neither radio is checked and `txtetp` does not exist**, which is
why prefill selects the mode first. Selecting a search *mode* is not human
verification, so LedgerPro may set it; the CAPTCHA and Verify always stay with
the user. The radio fires an ASP.NET postback, so the page reloads and prefill
runs again — the `checked` guard makes the second pass fill the number instead of
re-clicking, so it converges rather than looping. The portal step tells the user
about that reload.

**Result.** Pinned by `PortalFixtures.mpEtpGridFilled`, transcribed from a real
successful search:

```
S No | Lease Type | Lease No. | eTP NO. | Vehicle No. |
Date & Time of Transportation | Source Station | Destination Station |
Mineral Name | Mineral Qty
```

Three things about that layout drive the parser:

- The headers are **phrases**, so columns are matched by resolving them to a
  field. An exact-label gate matched only `eTP NO.`, `Vehicle No.` and
  `Mineral Name` — three of ten — which dropped the date and the quantity and
  failed every real capture with *"the portal result is missing: challan date,
  quantity"*.
- **`Mineral Qty` needs an explicit label.** It *contains* the longer needle
  `mineral`, so the longest-containing match would file the quantity as a second
  mineral name and leave the quantity empty.
- There is **no unit column**, so `quantity_unit` falls back to the stored
  default (`MT`). MP does carry `HiddenQtyInMT/CM/CF` hidden inputs, but hidden
  inputs are stripped before markup leaves the page, by design.

Two form ids are deliberately excluded from the id map: `lbletp` is the page's own
"Search by:" caption, and `txtetp` is the input LedgerPro prefills. Reading either
back would let a capture "succeed" on a page that returned nothing.

### Rendering MP at desktop width

MP's page is responsive, and at phone width it collapses to a mobile theme where
the eTP form is squeezed into a box barely wide enough to tap and the ten-column
result grid is unreadable. `ChallanPortal.prefersDesktopViewport` marks MP (only)
as needing desktop width, and on phones the portal screen applies three things
together — each is load-bearing:

1. a **desktop user agent**, so the portal's own CSS serves its desktop layout;
2. **Android's wide-viewport mode**, because `webview_flutter_android` defaults
   `useWideViewPort` to `false`, which makes the WebView ignore the page's
   viewport width entirely; and
3. an injected **`width=1280` viewport** with `initial-scale` computed from the
   real screen width, which `setLoadWithOverviewMode` (already on) then scales to
   fit. Zoom is enabled so the user can pinch into the grid.

macOS and Windows already host the WebView in a desktop-sized window, so
`needsDesktopViewportEmulation()` skips all of it there.

### Prefill is confirmed, not assumed

`PortalPrefillScript` builds the injected script and `PortalPrefillOutcome`
decodes what it achieved: `filled` (the number is confirmed present in the DOM),
`searchModeSelected`, or `notReady`. Only `filled` marks a page as prefilled, and
anything unproven is retried a bounded number of times.

That distinction is not cosmetic. Marking the page prefilled after merely
selecting MP's search mode raced the postback's own `onPageStarted`: the flag
could be set back to `true` *after* the reload had reset it, so the reloaded page
— the one that finally had the input — was skipped and the eTP box arrived empty.

### Navigation hand-off

`PortalNavigationPolicy.decide` distinguishes who asked. An off-host or
plain-HTTP **main-frame** navigation is the user following a link, so it opens in
the OS browser. The same URL in a **sub-frame** is the portal loading something
into its own page, and is refused quietly: launching the browser for it put a
"that link points outside the government portal" banner on every MP page load and
threatened to pull the user out mid-task through no action of their own.

### Live portal facts (verified against the real page)

Captured from `ViewPassDetailsNew.aspx` and pinned by fixtures in
`portal_result_fixtures.dart` (`realPortalUnsearched`, `realPortalFilled`,
`realPortalNoRecord`):

- **Every detail span ships with the literal text `NA`** until a search
  succeeds. `NA` (and `N/A`, `NIL`, `-`, `--`, `null`, `None`, …) is treated as
  **absent**, never as a value. Without this, an un-searched page looked like a
  partially-readable result and produced a misleading
  "missing: challan date, quantity" error.
- **The Bihar page has no CAPTCHA.** Its form is challan no + vehicle no +
  financial year + Search, so the copy leads with "press Search" and only
  mentions CAPTCHA where the portal actually shows one (Jharkhand does).
- Control ids are **flat** (`lblchallanno`, not `ctl00_…_lblchallanno`), so
  suffix matching covers both shapes.
- `lblunit` holds the quantity **unit** in its own control, separate from
  `lblquantity`.
- "Challan Generate from" is rendered by **`lbluser`**.
- The label is "Consig**ner** Name" (not "Consignor").
- `lblresult` / `lblMsg` carry the portal's own status line, e.g.
  "No Record Found" — read to distinguish *no such challan* from *not searched
  yet*. It is excluded from `dataFieldCount`, so it never counts as captured
  data.
- The financial-year dropdown uses exactly `2026-2027` formatting, matching the
  prefill.

### When the portal layout changes

Symptom: users report "Portal layout changed" or missing-field errors.

1. Reproduce by saving the new result page HTML as a fixture in
   `test/features/challans/fixtures/portal_result_fixtures.dart`.
2. Add the failing case to `challan_dom_parser_test.dart`.
3. Fix in the cheapest layer: add the new id suffix to `_idSuffixes` (layer 1),
   or the new label text to `_labels` (layer 2). Layer 3 usually needs no change.
4. Never relax mandatory-field validation to make an error go away — a partial
   capture must not be storable as `portal_captured`.

Users are never blocked: the manual-entry path always remains available and is
honestly labelled `manual_unverified`.

---

## 6. Database schema

Migration: **`supabase/migrations/20260725090000_epass_challan_material_entries.sql`**
(additive only; no existing migration was modified).

### `public.epass_challans`

Key columns: `organization_id`, `project_id`, `source_portal`
(default `bihar_khanan_soft`), `portal_url`, `financial_year`, `challan_number`,
`normalized_challan_number`, `uid_number`, `challan_date`, `valid_until`,
`selected_material_type`, `portal_mineral_name`, `quantity numeric(14,3)`,
`quantity_unit`, `vehicle_type`, `vehicle_number`, `normalized_vehicle_number`,
`consignor_name`, `consignee_name`, `source_location`, `destination`,
`generated_from`, `royalty_amount_paise`, `portal_payload jsonb`,
`portal_response_hash`, `verification_status`, `verification_method`,
`captured_at`, `verified_at`, `created_by`, `updated_by`, `created_at`,
`updated_at`, `deleted_at`.

Both the user's `selected_material_type` **and** the portal's
`portal_mineral_name` are stored. Neither is ever overwritten by the other.

Constraints:

- `quantity > 0`
- `royalty_amount_paise is null or royalty_amount_paise >= 0`
- `verification_status in (portal_captured, manual_unverified, official_api_verified, invalid, expired)`
- `verification_method in (webview_human_verification, manual_entry, official_api)`

Triggers:

- `epass_challans_normalize` — BEFORE INSERT OR UPDATE, recomputes both
  normalized columns server-side
- `set_updated_at` — repo-standard `ledger_private.set_updated_at()`
- `prevent_hard_delete` — repo-standard soft-delete enforcement

Indexes: `(organization_id, created_at desc)`, `(project_id, challan_date desc)`,
`normalized_challan_number`, `normalized_vehicle_number`, `portal_mineral_name`,
`verification_status` — all partial on `deleted_at is null`.

### Duplicate policy

```sql
create unique index epass_challans_unique_challan_idx
  on public.epass_challans (
    organization_id, source_portal, financial_year, normalized_challan_number
  )
  where deleted_at is null;
```

Scoped to **live rows only** (`where deleted_at is null`, set by migration
`20260726090000`). Deleting a challan therefore frees its number so the same
challan can be added again — which is the point of offering Delete rather than
Archive.

Checked at two levels:

1. **Flutter pre-check** (`challanExists`) — immediate UX, RLS-scoped so no other
   organization's data is ever visible.
2. **Postgres unique index + RPC** — the authority.

A duplicate raises SQLSTATE `23505` with a `DUPLICATE_CHALLAN:` message, which
`ChallanRepository.mapPostgrestError` turns into the exact user-facing string
**"This challan is already saved"** — never a generic server error. The dialog
shows the previous save date, project, material, vehicle number, an
"Open existing entry" action, and the saving user only for roles permitted to see
audit data.

Because the pre-check can race a concurrent insert, the RPC also catches
`unique_violation` from the insert itself and re-raises the same clear error.

### RPCs

| Function | Purpose |
|----------|---------|
| `create_epass_challan(...)` | Authenticates `auth.uid()`, resolves the org **from the project** (so the client cannot claim another org), verifies role, rejects `official_api`, normalizes server-side, duplicate-checks, inserts, writes a `challan_created` / `manual_challan_created` audit row, returns the row. All atomic. |
| `delete_epass_challan(uuid)` | Owner/manager only. Soft-delete plus `challan_deleted` audit row. Frees the challan number for re-entry. |
| `archive_epass_challan(uuid)` | Superseded by `delete_epass_challan`; kept so any older client keeps working. |
| `record_challan_duplicate_block(uuid, text)` | Writes the `duplicate_save_blocked` audit row. Separate function because `create_epass_challan` **raises** on a duplicate, which would roll back an audit row written in the same transaction. |

All are `security definer` with `set search_path = public, ledger_private, pg_temp`.
`list_epass_challans` was intentionally **not** created: direct RLS-protected
`select` with PostgREST filters is sufficient and keeps RLS as the single
authority.

`create_epass_challan` returns `public.epass_challans` (the row type), so the
client gets the authoritative saved record back rather than re-reading it.

---

## 7. RLS and roles

RLS is enabled. Policies reuse the existing helpers, so challan access is
consistent with the rest of the app:

```sql
-- read: any org member; customers narrowed to assigned projects
using (ledger_private.can_read_project_data(organization_id, project_id))

-- insert: owner / manager / accountant / site_staff, and the project must
--         belong to the same organization
-- update (archive): owner / manager only
```

| Role | View | Add | Delete | Export |
|------|:----:|:---:|:-------:|:------:|
| Owner | ✅ all | ✅ | ✅ | ✅ |
| Manager | ✅ all | ✅ | ✅ | ✅ |
| Accountant | ✅ all | ✅ | ❌ | ✅ |
| Site staff | ✅ accessible projects | ✅ | ❌ | ❌ |
| Viewer | ✅ read-only | ❌ | ❌ | ❌ |
| Customer | ✅ **only** assigned projects | ❌ | ❌ | ❌ |

Customer scoping comes from `ledger_private.can_read_project_data`, which routes
customers through `customer_project_assignments`.

Matching UI getters on `OrgPermissions`: `canViewChallans`, `canAddChallan`,
`canDeleteChallan`, `canExportChallans` (`canArchiveChallan` is retained as a
deprecated alias). **UI gating mirrors RLS but is never
the authority** — hiding a button neither grants nor denies access.

Grants: `select, insert, update` on the table to `authenticated` only (no
`delete` — soft-delete only). Execute on all three functions to `authenticated`,
revoked from `public` **and** `anon` (anon inherits PUBLIC, so revoking only from
anon would leave anonymous access open). Anonymous users have no challan access.

---

## 8. Material and expense accounting

**Saving a challan never creates a project expense.** A challan proves material
movement and transport details; it does not prove the payable amount.

When the portal supplies a royalty amount it is stored in
`royalty_amount_paise` on the challan and excluded from every project expense
total. The preview and detail screens both say so explicitly. A future
"Create Expense from Challan" action can add an expense only with explicit user
confirmation.

This keeps existing accounting totals unchanged by design.

---

## 9. Platform support and fallback matrix

`webview_flutter` is a federated plugin: `webview_flutter_android` implements
Android, `webview_flutter_wkwebview` implements iOS **and** macOS. Windows and
Linux have no implementation. The facade package declares no platform
restriction, so it is pure Dart there and **desktop builds still compile**.

| Platform | Portal | Capture status | Notes |
|----------|--------|----------------|-------|
| Android | In-app WebView | `portal_captured` | |
| iOS | In-app WebView | `portal_captured` | |
| macOS | In-app WebView (WKWebView) | `portal_captured` | |
| Windows | External browser | `manual_unverified` | Guarded by `ChallanPortalSupport` |
| Linux | External browser | `manual_unverified` | Guarded by `ChallanPortalSupport` |

`ChallanPortalSupport.supportsInAppWebView()` gates every WebView construction,
so no platform channel is touched where none exists. On Windows and Linux the
portal step shows a clearly-labelled fallback with "Open portal in browser" and
"Add manual entry"; the resulting record is honestly `manual_unverified`.

---

## 10. Offline behaviour

- `networkOnlineProvider` drives the UI; "Open Government Portal" is **disabled**
  offline with an explicit internet-required message.
- Already-saved challans remain viewable from the provider cache.
- A manual draft is allowed offline but is **always** `manual_unverified` — a
  fake verified record is never queued.
- The duplicate pre-check is skipped offline rather than failing; the server-side
  unique index still blocks duplicates on save.
- Global sync behaviour is unchanged. Portal verification genuinely requires
  internet and full offline verification is not a goal.

No Drift schema change was needed: the module reuses the existing provider-level
caching, so the local database is untouched (`schemaVersion` stays 1).

---

## 11. Realtime

`epass_challans` is added to `SupabaseLedgerApi.infraRealtimeTables` and to the
`supabase_realtime` publication via an idempotent `do $$ … exception when
duplicate_object` block. The table has `organization_id`, which the existing
channel filter requires.

`invalidateInfraProviders` handles challan events in a dedicated early-return
branch that invalidates only `challansProvider` and the specific
`challanByIdProvider`. Unrelated project providers are deliberately **not**
invalidated, because saving a challan does not change project financials. The
existing disposed-provider safeguards are preserved.

---

## 12. Audit and observability

Audit rows are written to `project_audit_logs` with `entity_table =
'epass_challans'`:

| Action | Written by |
|--------|-----------|
| `challan_created` | `create_epass_challan` |
| `manual_challan_created` | `create_epass_challan` (manual method) |
| `challan_deleted` | `delete_epass_challan` |
| `challan_archived` | `archive_epass_challan` (legacy) |
| `duplicate_save_blocked` | `record_challan_duplicate_block` |

Never logged or stored: CAPTCHA values, passwords, cookies, authorization
tokens, or full raw page HTML.

Stored instead: the normalized extracted payload (`portal_payload`), the capture
timestamp, and an optional SHA-256 `portal_response_hash` over the **normalized
field set** (not the page). Two devices reading the same result produce the same
hash, which is enough for support to confirm consistency without retaining
government content.

---

## 13. Test plan

```
test/features/challans/
├── fixtures/portal_result_fixtures.dart   Static HTML, never the live portal
├── challan_dom_parser_test.dart      19 tests
├── bihar_epass_adapter_test.dart     15 tests
├── challan_domain_test.dart          25 tests
├── challan_repository_test.dart      14 tests
├── challan_navigation_test.dart       9 tests
├── challan_screen_test.dart          19 tests
├── challan_flow_integration_test.dart 22 tests
└── challan_realtime_test.dart         9 tests
```

Coverage highlights:

- **Parser** — all three layers; English, Hindi and mixed bilingual markup;
  ASP.NET prefix churn; IST date parsing (all portal formats, timezone
  independence, invalid dates rejected); exact-decimal quantity; unit only when
  printed; rupees→paise integer math; entity decoding; malformed HTML never
  throws; stable response hash.
- **Adapter** — successful capture; challan mismatch; wrong financial year;
  financial-year boundary (a January date belongs to the previous April FY);
  no-record; layout changed; un-searched page; a throwing reader never leaks page
  content; host allow-list including the `…gov.in.evil.com` look-alike, plain
  HTTP, `javascript:` and `file://`.
- **Domain** — financial years derived from the clock (never pinned to 2026);
  material synonym matching; status/method round-trips checked against the DB
  check-constraint values; mandatory-field validation; permission getters for all
  six roles.
- **Repository** — full snake_case row mapping; numeric-as-string precision;
  nested join shapes; duplicate error mapping (`23505`, message and index name);
  permission/session/timeout mapping; unrecognized Postgres text never leaked.
- **Navigation regression** — bottom nav is `[Home, Projects, Expenses, Challan,
  Profile]`; "Reports" is gone from the nav; tablet rail and desktop sidebar;
  **project detail still has all five tabs including Reports**; report route
  constants preserved.
- **Screen** — five-step render; project-mandatory validation; challan
  upper-casing; offline state; read-only preview; material-mismatch gate;
  empty/populated list; permission gating per role; no overflow at 360 px.
- **Integration** — fixture HTML → capture → preview → mocked save → duplicate
  prevention, plus manual downgrade, save-failure recovery and flow navigation.
- **Realtime** — challan events refresh the list and detail; a soft-delete
  arriving as an update is handled; challan events do **not** churn project
  providers; expense events still refresh what they always did.

Run: `flutter test`

---

## 14. Deployment

### 1. Apply the migration

```bash
supabase db push --dry-run --linked   # verify only the new file is pending
supabase db push --linked
```

The migration is additive and idempotent (`create table if not exists`,
`create index if not exists`, `create or replace function`,
`drop policy if exists` before each `create policy`). It modifies no existing
migration and drops nothing. Each file runs in a transaction, so a failure rolls
back cleanly.

### 2. Verify Realtime

Confirm `epass_challans` is in the `supabase_realtime` publication:

```sql
select tablename from pg_publication_tables
where pubname = 'supabase_realtime' and tablename = 'epass_challans';
```

The migration adds it automatically; the statement is idempotent.

### 3. No Edge Function required

An authenticated PostgreSQL RPC provides authentication, membership and role
checks, server-side normalization, an atomic duplicate check, the insert and the
audit row in a single transaction. An Edge Function would add a network hop and a
second trust boundary without adding capability, so none was created.

### 4. Ship the app

No service-role key exists anywhere in the Flutter app. The client uses only the
anon key plus the signed-in user's JWT, exactly as before.

---

## 15. Troubleshooting

| Symptom | Cause | Action |
|---------|-------|--------|
| "Complete the CAPTCHA … then capture" | Search not pressed, or page still loading | Complete CAPTCHA, press the portal's Search, then Capture |
| "Portal layout changed" | Portal markup moved | Add a fixture + test, extend `_idSuffixes` / `_labels` (§5) |
| "The portal returned challan X, but you entered Y" | Portal searched for a different number | Re-search on the portal with the right number |
| "…does not belong to the selected financial year" | Wrong FY chosen | Pick the matching FY and capture again |
| "This challan is already saved" | Duplicate | Open the existing entry from the dialog |
| Invalid certificate warning | TLS chain untrusted | Do **not** enter credentials; verify the network, retry later |
| Prefill did not populate | Portal renamed its inputs | Type the values manually; extend the prefill selectors |
| Desktop cannot open the portal | Windows/Linux have no WebView | Use "Open portal in browser" + manual entry (§9) |
| "You do not have permission to add challans" | Viewer or customer role | Owner/manager must change the role |

---

## 16. Future official API adapter

The seam is already in place:

```dart
abstract interface class ChallanVerificationAdapter {
  String get sourcePortal;
  String get portalUrl;
  Future<ChallanCaptureResult> capture({
    required ChallanCaptureRequest request,
    required PortalHtmlReader readHtml,
  });
}
```

To adopt an authorized government API:

1. Implement an official-API adapter for that state, returning
   `status: officialApiVerified`, `method: officialApi`.
2. Point `challanVerificationAdapterProvider(portal)` at it for that portal.
3. Remove the `official_api` guard in `create_epass_challan`.

Nothing else changes: the flow controller, repository, RPC contract, database
schema and UI all speak `ChallanCaptureResult`, and the status vocabulary already
distinguishes a portal capture from a genuinely API-verified record. Records
captured before the switch keep their honest `portal_captured` status.
