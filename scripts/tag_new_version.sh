#!/bin/bash

set -e

changelog=`git log --graph --pretty=format:'%s%d' | sed -e '/tag: /,$ d'`
last_version=`git tag | grep -E "^[0-9]+\.[0-9]+\.[0-9]+" | sort --version-sort | tail -1`

# Clean up changelog
changelog_file=.tag_new_version_changelog
echo -e "# Clean up the changelog:\n" > $changelog_file
echo "$changelog" >> $changelog_file
$EDITOR $changelog_file
changelog=`cat $changelog_file | sed -e '/^#/ d'`
rm $changelog_file

# Input version
version_file=.tag_new_version_version
echo -e "$last_version\n\n# Type the version of the new release" > $version_file
echo "# Last version: $last_version" >> $version_file
echo "$changelog" | sed -e 's/^/# /g' >> $version_file
$EDITOR $version_file
version=`cat $version_file | sed -e '/^#/ d' | xargs`
rm $version_file

# Add headline to new changelog
date=`date +%Y-%m-%d`
sed -i -e "2 a ## $version $date\n" CHANGELOG.md

# Append new changelog
escaped_changelog=${changelog//$'\n'/\\$'\n'}
sed -i -e "4 a $escaped_changelog\n" CHANGELOG.md

# Update version in mix.exs
sed -i -e "s/$last_version/$version/" mix.exs

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
