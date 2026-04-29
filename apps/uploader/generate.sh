#!/bin/bash
set -euo pipefail

usage() {
  echo "使い方: $0 <タイトル> <bookId>"
  echo ""
  echo "例:"
  echo "  $0 \"カエルの王様\" kaeru-no-osama"
  exit 1
}

if [ $# -ne 2 ]; then
  usage
fi

TITLE="$1"
BOOK_ID="$2"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"
npm run generate -- "$TITLE" "$BOOK_ID"
