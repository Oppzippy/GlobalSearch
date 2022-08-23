#!/usr/bin/env python3

from typing import Dict, List
import xml.etree.ElementTree as ET
import requests
import re

source_file_urls = {
    "default": [
        "https://raw.githubusercontent.com/BigWigsMods/WoWUI/live/FrameXML/InterfaceOptionsPanels.lua",
        "https://raw.githubusercontent.com/BigWigsMods/WoWUI/live/FrameXML/InterfaceOptionsPanels.xml",
    ],
    0: [
        "https://raw.githubusercontent.com/BigWigsMods/WoWUI/vanilla/Interface_Vanilla/FrameXML/InterfaceOptionsPanels.lua",
        "https://raw.githubusercontent.com/BigWigsMods/WoWUI/vanilla/Interface_Vanilla/FrameXML/InterfaceOptionsPanels.xml",
    ],
    1: [
        "https://raw.githubusercontent.com/BigWigsMods/WoWUI/tbc/Interface_TBC/FrameXML/InterfaceOptionsPanels.lua",
        "https://raw.githubusercontent.com/BigWigsMods/WoWUI/tbc/Interface_TBC/FrameXML/InterfaceOptionsPanels.xml",
    ],
}

xml_namespace = "{http://www.blizzard.com/wow/ui/}"
lua_on_load_function_regex = re.compile(
    r"^\s*function (InterfaceOptions[A-Za-z]+Panel)_OnLoad\s*\(\s*self\s*\)\s*$(.*?)^end\s*$",
    re.MULTILINE | re.DOTALL,
)
options_assignment_regex = re.compile(r"self.options *= *(\w+)")


def parse_lua(text: str) -> Dict[str, str]:
    options_to_frames = {}
    for match in lua_on_load_function_regex.finditer(text):
        frame_name = match.group(1)
        function_content = match.group(2)
        options_assignment_match = options_assignment_regex.search(function_content)
        if options_assignment_match is not None:
            options_name = options_assignment_match.group(1)
            options_to_frames[options_name] = frame_name
    return options_to_frames


def parse_xml(root: ET.Element) -> Dict[str, str]:
    options_to_frames = {}
    frames = root.findall(f"{xml_namespace}Frame")
    for frame in frames:
        on_load = frame.find(f"{xml_namespace}Scripts/{xml_namespace}OnLoad")
        if on_load is not None and on_load.text is not None:
            match = options_assignment_regex.search(on_load.text)
            if match is not None:
                frame_name = frame.get("name")
                options_name = match.group(1)
                options_to_frames[options_name] = frame_name
    return options_to_frames


def get_options_to_frames(urls: List[str]) -> Dict[str, str]:
    options_to_frames = {}
    for url in urls:
        with requests.get(url) as response:
            if url.endswith(".xml"):
                options_to_frames.update(parse_xml(ET.fromstring(response.text)))
            elif url.endswith(".lua"):
                options_to_frames.update(parse_lua(response.text))
    return options_to_frames


assignments = []
for key, urls in source_file_urls.items():
    lines = []
    options_to_frames = get_options_to_frames(urls)
    lua_key = f'"{key}"' if isinstance(key, str) else str(key)
    lines.append(f"ns.InterfaceOptionsPanels[{lua_key}] = {{")
    for options, frame in options_to_frames.items():
        lines.append(f"\t{{ options = {options}, frame = {frame} }},")
    lines.append("}")
    assignments.append("\n".join(lines))

print(
    """---@class ns
local ns = select(2, ...)

ns.InterfaceOptionsPanels = {}
"""
)

print("\n\n".join(assignments))
