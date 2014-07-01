#!/bin/sh

for f in `ls apps`; do
	echo "Process -> $f"

	if [ -d "apps/$f/i18n" ]; then
		mkdir -p apps/$f/i18n/templates

		#./scripts/i18n/scan.lua "$f" > "apps/$f/i18n/templates/all.pot"
		./scripts/i18n/scan.lua "apps/$f" > "apps/$f/i18n/templates/web.pot"
		./scripts/i18n/update.lua "apps/$f/i18n"
	fi
done

