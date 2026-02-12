AGENTS.md - Constitution du Projet "Résidence L'Amandier B" (Flutter Edition)
@Context Role: Senior Flutter Architect & UI/UX Specialist. Stack: Flutter (Dart 3+), Supabase (Remote DB), Drift (Local SQL), Riverpod (State). Design System: "Luxury Real Estate" (Gold/Dark Navy/White palette, Serif fonts for headers). Reliability: "Military Grade" - App must run 2 years without maintenance.

@Architecture Rules (Strict MVI)

PATTERN: Model-View-Intent (MVI).
State: ONE immutable Data Class per screen using Freezed.
Logic: Pure business logic in Domain layer UseCases.
LAYERS (Clean Architecture):
lib/core: Shared logic, error handling, extensions.
lib/data: Repositories, Drift Database, Supabase Client.
lib/domain: Entities, UseCases, Failures.
lib/presentation: Widgets, ViewModels (Riverpod Notifiers).
OFFLINE-FIRST STRATEGY:
READ from Local DB (Drift).
WRITE to Queue -> Sync to Supabase when online.
Images: Stored locally + Supabase Storage. Auto-Delete logic mandatory when incident is closed.
@Roles & Permissions (RBAC)

SYNDIC: All Access (Read/Write Financials & Incidents).
ADJOINT: Read-Only Financials, Read/Write Incidents (Close only).
CONCIERGE: Read Technical Incidents (Filter out complaints about "Concierge").
RESIDENT: Read Own Data, Write Incidents, Blog, SOS.
@Business Logic

LOGIN: Floor (1-3) -> Apt (1-5) -> Name -> Pin Code.
FINANCIAL HEALTH:
Green: > 3 months budget.
Orange: < 3 months budget.
Red: Deficit.
SOS BUTTON: "Slide to Confirm" interaction. Triggers high-priority push notification.
DOCUMENT SECURITY: All generated PDFs must include a cryptographically signed QR Code.
@Forbidden

DO NOT use GetX. Use Riverpod with code generation.
DO NOT use standard Material Widgets for main UI. Create Custom "Luxury" Widgets.
DO NOT allow deleting financial history logs (Audit Trail).
DO NOT keep incident photos after resolution (Storage optimization).
