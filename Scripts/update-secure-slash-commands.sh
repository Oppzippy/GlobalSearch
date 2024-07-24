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
	urls["\"default\""]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/live/AddOns/Blizzard_ChatFrameBase/Mainline/ChatFrame.lua"
	urls["0"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/vanilla/Interface/AddOns/Blizzard_ChatFrameBase/Classic/ChatFrame.lua"
	urls["1"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/tbc/Interface/FrameXML/ChatFrame.lua"
	urls["2"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/wrath/Interface/FrameXML/ChatFrame.lua"
	urls["3"]="https://raw.githubusercontent.com/BigWigsMods/WoWUI/cata/Interface/AddOns/Blizzard_ChatFrameBase/Classic/ChatFrame.lua"

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
