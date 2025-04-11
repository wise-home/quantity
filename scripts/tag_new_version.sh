#!/usr/bin/env bash

set -e

# find the appropriate version of sed to use.
# on BSDs, gsed is typically the gnu version of sed, typically installed via homebrew
SED=$(command -v gsed || command -v sed || exit 1)

changelog=`git log --no-show-signature --graph --pretty=format:'%s%d' | "$SED" -e '/tag: /Q'`
last_version=`git tag | grep -E "^[0-9]+\.[0-9]+\.[0-9]+" | sort --version-sort | tail -1`

# Clean up changelog
changelog_file=.tag_new_version_changelog
echo -e "# Clean up the changelog:\n" > $changelog_file
echo "$changelog" >> $changelog_file
$EDITOR $changelog_file
changelog=`cat $changelog_file | "$SED" -e '/^#/ d'`
rm $changelog_file

# Input version
version_file=.tag_new_version_version
echo -e "$last_version\n\n# Type the version of the new release" > $version_file
echo "# Last version: $last_version" >> $version_file
echo "$changelog" | "$SED" -e 's/^/# /g' >> $version_file
$EDITOR $version_file
version=`cat $version_file | "$SED" -e '/^#/ d' | xargs`
rm $version_file

# Add headline to new changelog
date=`date +%Y-%m-%d`
"$SED" -i -e "2 a ## $version $date\n" CHANGELOG.md

# Append new changelog
escaped_changelog=${changelog//$'\n'/\\$'\n'}
"$SED" -i -e "4 a $escaped_changelog\n" CHANGELOG.md

# Update version in mix.exs
"$SED" -i -e "s/$last_version/$version/" mix.exs

# Check if new version was set
# useful when there is discrepancy between mix.ex and actual git tags
if ! grep -q "version: \"$version\"" mix.exs; then
  echo "New version was not set in mix.exs file!"
  exit 1
fi

# Stage changes
files="CHANGELOG.md mix.exs"
git add -p $files

# Any changes made during staging should be written to file
git checkout $files

read -p "All good to submit to git? Press <ENTER> to continue. (Abort with Ctrl+C if not) "

# Tag and commit
git add $files
git commit -m "Bump $version"
git push
git tag -a $version -m "$version"
git push -u origin $version
