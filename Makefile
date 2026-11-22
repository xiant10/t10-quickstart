# The targets every t10 sub project has (the workspace's proposals/dev-loop.md).
# This repo has no CI of its own; make ci is what a change needs before it's pushed.
# make test starts a whole stack from the pinned images, on the ports yours
# uses: stop yours first.

.PHONY: lint test ci

# Every Compose file still parses, the way the README and check.sh use it.
lint:
	docker compose -f compose.yml config -q
	docker compose -f compose.yml -f compose.dev.yml config -q
	docker compose -f compose.yml -f scripted/compose.yml config -q
	docker compose -f compose.all.yml config -q

test:
	./check.sh

ci: lint test
