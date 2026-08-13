# SessionHero — submission notes for graders

An open-source SessionBoard clone built on Ruby on Rails 8.1 (Hotwire, daisyUI,
SQLite, Active Storage). Password authentication — **no magic links or OAuth**,
so every persona can sign in directly with the credentials below.

## Seeded demo event
**DevFlow Conf 2027** is fully populated on boot (`bin/rails db:seed`): 17
sessions across 3 tracks / 4 rooms / 3 days, 10 speakers, a scored review round,
onboarding tasks, a two-version slide deliverable, email templates, and a CRM
directory. The public agenda is already published.

## Credentials (password login)
| Persona   | Email                        | Password            |
|-----------|------------------------------|---------------------|
| Organizer | sbek-organizer@example.com   | SbekTest!2027-org   |
| Speaker   | sbek-speaker@example.com     | SbekTest!2027-spk   |
| Speaker 2 | sbek-speaker2@example.com    | SbekTest!2027-spk2  |
| Reviewer  | sbek-reviewer@example.com    | SbekTest!2027-rev   |
| Attendee  | sbek-attendee@example.com    | SbekTest!2027-att   |

Signing up with a new email also works; the public CFP form creates a speaker
account automatically.

## Where things live (event slug: `devflow-conf-2027`)
- **Public site / widgets** (no login): `/events/devflow-conf-2027/site`,
  `/sessions`, `/speakers`, `/agenda`, `/events/.../itinerary`, `/events/.../gallery`.
  Top-level `/sessions`, `/speakers`, `/agenda` redirect to the featured event.
  Embeds: `/events/.../embed/<widget>`; feeds: `/events/.../feed/<widget>.json|.ics`.
- **Organizer console**: `/events/devflow-conf-2027/manage` — Sessions, Submission
  Forms, Evaluation, Speakers, Tasks, Agenda, Files & Content, Communications,
  Embeds, Email Templates, Settings.
- **Speaker portal** (log in as a speaker): `/portal`.
- **Reviewer area** (log in as the reviewer): `/events/devflow-conf-2027/review`.
- **Speaker CRM** (org-level, cross-event): `/crm`.
- **Public call-for-papers form** (shareable, no login): `/events/devflow-conf-2027/submit`.

## Notes
- Decisions (accept/reject) never auto-email; notifications are a separate step
  under Communications, which logs every send in an in-app history.
- Email delivery is best-effort (no SMTP configured in the demo); the auditable
  record is the Communications history log.
