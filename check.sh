#!/usr/bin/env bash
# Proves the stack works with no provider or key: starts a separate copy with a
# scripted model, sends one turn and one tool call straight at the harness, and
# removes it. A change that needs a gateway fails here. Stop your own stack
# first, because they use the same ports. Set DEV=1 to build from sibling
# checkouts, as the t10 workspace's `make light-smoke` does.
set -euo pipefail
cd "$(dirname "$0")"

export LLM_BASE_URL=http://fake-model:8080 LLM_API_KEY=unused FAST_MODEL_ID=scripted SMART_MODEL_ID=scripted
files=(-f docker-compose.yml -f scripted/compose.yml)
[ -z "${DEV:-}" ] || files+=(-f compose.dev.yml)
compose() { docker compose -p t10-quickstart-check "${files[@]}" "$@"; }
[ "${KEEP:-}" = 1 ] || trap 'compose down -v --remove-orphans >/dev/null 2>&1' EXIT

# Start clean, so a copy left by KEEP=1 can't add its rows to the count below.
compose down -v --remove-orphans >/dev/null 2>&1
compose up -d --build --wait --quiet-pull

token=$(curl -fsS http://127.0.0.1:18081/v1/token \
	-d grant_type=password -d client_id=t10-mac-client \
	-d username=ada@acme.example -d password=change-me-enterprise-admin \
	-d tenant=ten_acme | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

rpc() { # method, params, session
	curl -fsS http://127.0.0.1:19800/agent -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
		-H "Agent-Method: $1" ${3:+-H "Agent-Session-Id: $3"} \
		-d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"$1\",\"params\":$2}"
}

session=$(rpc session.create '{}' | sed -n 's/.*"sessionId":"\([^"]*\)".*/\1/p')
reply=$(rpc session.prompt '{"input":"tell me about the light profile"}' "$session")
case "$reply" in
*'light profile reply'*) ;;
*) echo "no reply from the harness: $reply" >&2; exit 1 ;;
esac

# A provider called directly must see no user, tenant or session ID.
identity=$(compose exec -T fake-model node -e "fetch('http://127.0.0.1:8080/seen').then(r=>r.text()).then(t=>process.stdout.write(t))")
[ "$identity" = '[]' ] || { echo "identity headers reached the provider: $identity" >&2; exit 1; }

session=$(rpc session.create '{}' | sed -n 's/.*"sessionId":"\([^"]*\)".*/\1/p')
reply=$(rpc session.prompt '{"input":"work create: create a new work item for the user"}' "$session")
case "$reply" in
*'created wi_'*) ;;
*) echo "the tool result never reached the model: $reply" >&2; exit 1 ;;
esac
granted=$(compose exec -T postgres psql -tA -U t10 -d collab -c "select count(*) from collab.events where actor_grant_id is not null")
[ "$granted" = 1 ] || { echo "the tool call ran without a grant: $granted" >&2; exit 1; }

curl -fsS -o /dev/null http://127.0.0.1:18083/readyz
echo "ok    one turn and one granted tool call, with no gateway and no identity sent to the model"
