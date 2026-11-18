# AGENTS.md

For coding agents working in this repo. The lightweight profile, published: auth-server, agent-pi, t10-collab and workbench in Compose, from pinned commits of the public repos.

## Build and test

```bash
./check.sh                      # against the pinned images
make light-smoke                # from the workspace: against the checkouts beside it
```

## Read first

- `README.md`

## Rules

- Everything here is public: only public repos and placeholder secrets.
- A route change updates `docs/api.md` (and `docs/openapi.yaml` where there is one) in the same change.
- Every doc under `docs/` starts with front matter: `title`, `audience` (consumer, contributor or operator), `kind` (guide, reference, design or record), `status` and `summary`. Plans, reviews and validation logs go in `docs/records/`. The workspace's `make check` (`scripts/check-docs.py`) holds this and checks relative links.
- This repo is its own project inside the t10 workspace: it builds with nothing from the workspace. The workspace's `ARCHITECTURE.md` is the high-level design, and wins where they disagree.
- This repo is public: check what you add before it's pushed.
