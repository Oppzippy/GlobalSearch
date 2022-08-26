#!/bin/bash
set -e
set -o pipefail

exit_code=0
declare -A seen_names
declare -A seen_duplicates

while IFS=$'\t' read -r file_name line_number localized_name; do
	if [[ -z "${seen_names["$localized_name"]}" ]]; then
		seen_names["$localized_name"]="$file_name:$line_number"
	else
		exit_code="1"
		if [[ -z "${seen_duplicates["$localized_name"]}" ]]; then
			seen_duplicates["$localized_name"]=1
			echo "${seen_names["$localized_name"]} Found duplicate localized name: $localized_name"
		fi
		echo "$file_name:$line_number Found duplicate localized name: $localized_name"
	fi
done <<< "$(awk -v OFS="\t" 'match($0, /^\s*localizedName\s*=\s*([^,]*)?,?\s*$/, groups) { print FILENAME, FNR, groups[1] }' SearchProviders/*)"

exit $exit_code
