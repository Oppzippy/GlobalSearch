#!/bin/bash
set -e
set -o pipefail

get_slash_commands_from_url() {
	echo "{"
	curl -s -S "$1" | sed -n -E "s/^.*SecureCmdList\[\"(\w+)\"] *= *function.*$/\t\"\1\",/p"
	echo "}"
}

get_slash_commands_for_all_versions() {
	declare -A urls
	urls["\"default\""]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/live/FrameXML/ChatFrame.lua"
	urls["0"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/vanilla/Interface/FrameXML/ChatFrame.lua"
	urls["1"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/tbc/Interface/FrameXML/ChatFrame.lua"
	# TODO change to wrath branch when it is added
	urls["2"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/tbc/Interface/FrameXML/ChatFrame.lua"

	for key in "${!urls[@]}"; do
		echo ""
		echo -n "ns.SecureSlashCommandLists[$key] = "
		get_slash_commands_from_url "${urls[$key]}"
	done
}

cat << EOF
---@class ns
local ns = select(2, ...)
ns.SecureSlashCommandLists = {}
EOF
get_slash_commands_for_all_versions
