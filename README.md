# SessionHero

A self-hostable events platform for organizing conferences and collecting
speaker submissions — create an event, share a public Call for Papers link, and
review proposals. One user identity carries per-event roles, so the same person
can organize one event and speak at another.

## Highlights

- **Unified dashboard** grouping your events by role (Managing / Speaking).
- **Events & CFP** — create an event and share a public submission link; no
  account needed to open the form.
- **Contextual roles** — `EventMembership` scopes each role (organizer /
  speaker / reviewer) to a single event; an organizer who submits with their own
  email simply gains a speaker role too.
- **Organizer backstage** at `/events/:slug/manage` to review submissions and
  set their status.
- **Reusable speaker profile** (`/profile`), global across events.
- **Separate admin area** (`/admins`) for platform staff.

## Tech stack

- Ruby on Rails 8.1
- Devise for authentication (separate `User` and `Admin` scopes)
- HAML views, simple_form (daisyUI-themed wrappers)
- Tailwind CSS + daisyUI (custom "facebook" theme)
- SQLite (development), RSpec + FactoryBot

## Getting started

```bash
bundle install
bin/rails db:prepare          # create + migrate + seed
bin/rails tailwindcss:build   # build the stylesheet
bin/rails server              # http://localhost:3000
```

Then sign up at `/users/sign_up`, create an event, and share its CFP link.

## License

SessionHero is **source-available** under the **Apache License 2.0 with the
[Commons Clause](https://commonsclause.com/)** — see [LICENSE.md](LICENSE.md).

- ✅ You may **self-host, modify, and use** it, including to run your own events
  with **paid admission** — the tickets derive their value from your event, not
  from the software.
- ❌ You may **not "Sell" the software** — offering its functionality to third
  parties for a fee (hosting it as a service, white-labeling, or reselling it).

A separate commercial license from the copyright holder is required for those
uses. Copyright © 2026 William Estoque.

## Contributing

Contributions are welcome. Because the project is dual-licensable (the copyright
holder may offer commercial licenses and relicense future versions), all
contributions require agreement to the [Contributor License Agreement](CLA.md).
By submitting a pull request you agree to its terms.
