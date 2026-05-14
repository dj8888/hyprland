#!/usr/bin/env bash
# search.sh — Ponti's SearXNG bridge. Hardcoded tool, called by the orchestrator
# AFTER it has deterministically decided a search is needed. The model never
# invokes this; it only receives the formatted output.

set -u
QUERY="${1:-}"
[[ -z "$QUERY" ]] && exit 0

SEARXNG_URL="${SEARXNG_URL:-http://127.0.0.1:8888}"
N="${SEARCH_RESULTS:-5}"
SNIPPET_LEN="${SEARCH_SNIPPET_LEN:-280}"

curl -sf --max-time 6 -G "$SEARXNG_URL/search" \
  --data-urlencode "q=$QUERY" \
  --data-urlencode "format=json" 2>/dev/null \
  | jq -r --argjson n "$N" --argjson s "$SNIPPET_LEN" '
    .results[:$n] | map(
      "• " + (.title // "untitled") +
      "\n  " + ((.content // "") | gsub("\\s+"; " ") | .[0:$s])
    ) | join("\n")
  '
