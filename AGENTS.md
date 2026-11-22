# AGENTS.md

For coding agents working in this repo. The lightweight profile, published: auth-server, agent-pi, t10-collab and workbench in Compose (`compose.yml`), from images pinned by commit; `compose.all.yml` runs every component the same way.

## Build and test

```bash
make lint                 # every Compose file parses
make test                 # ./check.sh, against the pinned images; stop your own stack first
make ci                   # what a change needs before it's pushed
make light-smoke          # from the workspace: against the checkouts beside it
```

## Read first

- `README.md`

## Rules

- Everything here is public: only public images and placeholder secrets.
- Move the image pins in `compose.yml` and `compose.all.yml` together, to `sha-` tags of each repo's `main` that `ghcr.io` has, run `./check.sh` and bring `compose.all.yml` up, then tag the commit `vYYYY.MM.DD` (a `.N` suffix for a second one that day).
- A route change updates `docs/api.md` (and `docs/openapi.yaml` where there is one) in the same change.
- Every doc under `docs/` starts with front matter: `title`, `audience` (consumer, contributor or operator), `kind` (guide, reference, design or record), `status` and `summary`. Plans, reviews and validation logs go in `docs/records/`. The workspace's `make check` (`scripts/check-docs.py`) holds this and checks relative links.
- This repo is its own project inside the t10 workspace: it builds with nothing from the workspace. The workspace's `ARCHITECTURE.md` is the high-level design, and wins where they disagree.
- This repo is public: check what you add before it's pushed.
