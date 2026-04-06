#!/usr/bin/env python3
"""Generate an iTerm2 Dynamic Profile JSON file.

Uses only Python stdlib. Outputs a JSON file suitable for placement in:
    ~/Library/Application Support/iTerm2/DynamicProfiles/

Usage:
    python3 generate-profile.py --name "My Profile"
    python3 generate-profile.py --name "Dev" --colors schemes/Solarized.itermcolors --output profile.json
"""

import argparse
import json
import os
import plistlib
import sys
import tempfile
import uuid


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate an iTerm2 Dynamic Profile JSON"
    )
    parser.add_argument("--name", required=True, help="Profile name")
    parser.add_argument(
        "--font", default="MesloLGS-NF", help="Font PostScript name (default: MesloLGS-NF)"
    )
    parser.add_argument(
        "--font-size", type=int, default=13, help="Font size (default: 13)"
    )
    parser.add_argument(
        "--colors", help="Path to .itermcolors file"
    )
    parser.add_argument(
        "--guid", default=None, help="Profile GUID (default: random UUID)"
    )
    parser.add_argument(
        "--output", default=None, help="Output file path (default: stdout)"
    )
    return parser.parse_args()


def load_itermcolors(path):
    """Load an .itermcolors plist and convert to Dynamic Profile color format."""
    try:
        with open(path, "rb") as f:
            colors = plistlib.load(f)
    except Exception as e:
        sys.exit(f"error: cannot read itermcolors file: {e}")

    result = {}
    for key, value in colors.items():
        if not isinstance(value, dict):
            continue
        color = {}
        # Map Color Space Name -> Color Space
        if "Color Space Name" in value:
            color["Color Space"] = value["Color Space Name"]
        elif "Color Space" in value:
            color["Color Space"] = value["Color Space"]

        # Normalize color components to float
        for component in ("Red Component", "Green Component", "Blue Component"):
            if component in value:
                color[component] = float(value[component])

        # Default alpha to 1.0
        color["Alpha Component"] = float(value.get("Alpha Component", 1.0))

        result[key] = color

    return result


def build_profile(name, font, font_size, guid, colors):
    """Build the profile dictionary."""
    font_string = f"{font} {font_size}"

    profile = {
        "Name": name,
        "Guid": guid,
        "Dynamic Profile Parent Name": "Default",
        "Normal Font": font_string,
        "Non Ascii Font": font_string,
        "Use Non-ASCII Font": False,
        "Option Key Sends": 2,
        "Unlimited Scrollback": True,
        "Custom Directory": "Recycle",
    }

    if colors:
        profile.update(colors)

    return profile


def write_output(data, output_path):
    """Write JSON output, using atomic writes for files."""
    json_str = json.dumps(data, indent=2, ensure_ascii=False) + "\n"

    if output_path is None:
        sys.stdout.write(json_str)
        return

    # Atomic write: tempfile in same directory, then rename
    output_dir = os.path.dirname(os.path.abspath(output_path))
    try:
        os.makedirs(output_dir, exist_ok=True)
        fd, tmp_path = tempfile.mkstemp(dir=output_dir, suffix=".json.tmp")
        try:
            with os.fdopen(fd, "w") as f:
                f.write(json_str)
            os.rename(tmp_path, output_path)
        except Exception:
            os.unlink(tmp_path)
            raise
    except Exception as e:
        sys.exit(f"error: cannot write output: {e}")


def main():
    args = parse_args()

    guid = args.guid or str(uuid.uuid4())

    colors = None
    if args.colors:
        colors = load_itermcolors(args.colors)

    profile = build_profile(args.name, args.font, args.font_size, guid, colors)
    data = {"Profiles": [profile]}

    write_output(data, args.output)


if __name__ == "__main__":
    main()
