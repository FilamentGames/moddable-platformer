#!/usr/bin/env bash
# Builds the Pages site: web editor release + one folder per chapter build.
# Requires: GH_TOKEN, GODOT_REPO, GITHUB_REPOSITORY, GITHUB_WORKSPACE (set by pages.yml / Actions).
set -euo pipefail
mkdir -p site dl

# Newest fila-* release (incl. prereleases) that has a web-editor asset
tag=$(gh api "repos/$GODOT_REPO/releases?per_page=30" --jq \
  '[.[] | select(.tag_name | startswith("fila-"))
        | select(any(.assets[]; .name | startswith("web-editor-")))][0].tag_name // empty')
[ -n "$tag" ] || { echo "No fila-* web-editor release found" >&2; exit 1; }
echo "Using $GODOT_REPO release $tag"
gh release download "$tag" --repo "$GODOT_REPO" --pattern 'web-editor-*.zip' --output dl/WEB_EDITOR.zip

unzip -o dl/WEB_EDITOR.zip -d dl/web
mv dl/web/* site/
mkdir -p site/chapters

# fetch_artifact <artifact name> <artifact id> <output zip path>
# Downloads a build artifact and re-zips it so the archive has explicit
# directory entries; the web editor's zip installer needs them.
fetch_artifact() {
  local name="$1" id="$2" out="$3"
  mkdir -p "$(dirname "$out")" "dl/x/$name"
  gh api "repos/$GITHUB_REPOSITORY/actions/artifacts/$id/zip" > "dl/$name.zip"
  unzip -q "dl/$name.zip" -d "dl/x/$name"
  (cd "dl/x/$name" && zip -qr "$GITHUB_WORKSPACE/$out" .)
  test -f "$out" || { echo "$out missing" >&2; exit 1; }
}

# Newest unexpired artifact per name (API lists newest first).
gh api --paginate "repos/$GITHUB_REPOSITORY/actions/artifacts?per_page=100" --jq \
  '.artifacts[] | select(.expired | not) | select(.name | test("^(debug-)?project-")) | "\(.name) \(.id)"' \
  | awk '!seen[$1]++' > dl/artifacts.txt

# >>> TEST ONLY (delete this block and the TEST_ONLY_CHAPTER check below to undo) >>>
TEST_ONLY_CHAPTER="pages-multiProjects"
grep -E "^(debug-)?project-$TEST_ONLY_CHAPTER " dl/artifacts.txt > dl/artifacts.filtered.txt || true
mv dl/artifacts.filtered.txt dl/artifacts.txt
# <<< TEST ONLY <<<

cat dl/artifacts.txt

# Chapters = every branch that has a project-<chapter> artifact.
: > dl/chapters.txt
while read -r name id; do
  chapter="${name#project-}"
  echo "Chapter $chapter (artifact $id)"
  fetch_artifact "$name" "$id" "site/chapters/$chapter/project.zip"
  echo "$chapter" >> dl/chapters.txt
  dbg=$(awk -v n="debug-$name" '$1==n {print $2}' dl/artifacts.txt)
  if [ -n "$dbg" ]; then
    fetch_artifact "debug-$name" "$dbg" "site/chapters/$chapter/debug-project.zip"
  else
    echo "::warning::No debug-project artifact for chapter $chapter"
  fi
done < <(grep -v '^debug-' dl/artifacts.txt)

if [ -n "${TEST_ONLY_CHAPTER:-}" ]; then # TEST ONLY: main is skipped
  test -f "site/chapters/$TEST_ONLY_CHAPTER/project.zip" || { echo "Test chapter '$TEST_ONLY_CHAPTER' has no build" >&2; exit 1; }
else
  test -f site/chapters/main/project.zip || { echo "Default chapter 'main' has no build" >&2; exit 1; }
fi
jq -R . dl/chapters.txt | jq -s '{chapters: .}' > site/chapters/index.json

test -f site/godot.editor.html || { echo "godot.editor.html missing" >&2; exit 1; }
cp site/godot.editor.html site/index.html
