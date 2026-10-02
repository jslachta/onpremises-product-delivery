#!/bin/sh
# =====================================================================
#  Verze dokumentu počítaná z gitu.
#
#  Použití:  sh scripts/version.sh [výstup.tex]      (výchozí version.tex)
#
#  • HEAD přesně na tagu vX.Y.Z a čistý strom  → vydání, verze "X.Y.Z"
#  • cokoli jiného                              → draft,
#      verze "draft-<git describe>", např. draft-v1.2.0-3-gabc1234,
#      draft-abc1234 (zatím žádný tag), draft-…-dirty (neuložené změny)
#
#  Zapíše version.tex (makra \docversion, \doccommit, \docdate a přepínač
#  \ifdocdraft) — soubor se přepíše jen při změně obsahu, aby make
#  zbytečně nepřestavoval PDF.
#  Na stdout vypíše KEY=value řádky (VERSION, TAG, COMMIT, DOC_DATE,
#  DRAFT) — CI je přesměruje do $GITHUB_ENV.
# =====================================================================
set -eu

OUT="${1:-version.tex}"

DESC="$(git describe --tags --match 'v[0-9]*.[0-9]*.[0-9]*' --always --dirty 2>/dev/null || echo unknown)"
COMMIT="$(git rev-parse --short=7 HEAD 2>/dev/null || echo unknown)"

if printf '%s\n' "$DESC" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  DRAFT=false
  TAG="$DESC"
  VERSION="${DESC#v}"
  # Datum vydání = datum commitu → opakovaný build dá totéž PDF.
  DOC_DATE="$(git log -1 --format=%cs HEAD)"
else
  DRAFT=true
  TAG=""
  VERSION="draft-${DESC}"
  DOC_DATE="$(date -u +%Y-%m-%d)"
fi

TMP="${OUT}.tmp"
{
  printf '%% Generováno scripts/version.sh — needitovat, necommitovat.\n'
  printf '\def\docversion{%s}\n' "$VERSION"
  printf '\def\doccommit{%s}\n'  "$COMMIT"
  printf '\def\docdate{%s}\n'    "$DOC_DATE"
  printf '\docdraft%s\n'          "$DRAFT"
} > "$TMP"

if [ -f "$OUT" ] && cmp -s "$TMP" "$OUT"; then
  rm -f "$TMP"
else
  mv -f "$TMP" "$OUT"
fi

echo "Verze: ${VERSION} | commit: ${COMMIT} | datum: ${DOC_DATE}" >&2

printf 'VERSION=%s\nTAG=%s\nCOMMIT=%s\nDOC_DATE=%s\nDRAFT=%s\n' \
  "$VERSION" "$TAG" "$COMMIT" "$DOC_DATE" "$DRAFT"
