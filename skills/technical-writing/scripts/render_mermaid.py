#!/usr/bin/env python3
"""Render every Mermaid block of a Markdown file, to check it before a reader sees it.

Usage:
    python3 render_mermaid.py <file.md> <out-dir>

For each ```mermaid block, the script writes <out-dir>/<file-stem>-<n>.png and prints
one line: OK, PARSE ERROR with Mermaid's message, or BAD LABEL when Mermaid replaced a
label with "Unsupported markdown". It exits with status 1 if any block is not OK.

It needs a Chromium-based browser and network access: it loads Mermaid from jsDelivr.
Set CHROME to the browser binary if the script does not find one. Set MERMAID_VERSION
to check against the version your renderer uses (GitLab and GitHub each pin their own).
"""

import html
import os
import pathlib
import re
import shutil
import subprocess
import sys

MERMAID_VERSION = os.environ.get("MERMAID_VERSION", "11.4.1")
MERMAID_URL = f"https://cdn.jsdelivr.net/npm/mermaid@{MERMAID_VERSION}/dist/mermaid.esm.min.mjs"

BROWSERS = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    "google-chrome",
    "chromium",
    "chromium-browser",
    "brave-browser",
    "microsoft-edge",
]

PAGE = """<!doctype html>
<meta charset="utf-8">
<body style="margin:16px;background:#fff">
<pre id="source" style="display:none">{source}</pre>
<div id="diagram"></div>
<div id="status" hidden>PENDING</div>
<script type="module">
const status = document.getElementById('status');
try {{
  const mermaid = (await import('{mermaid_url}')).default;
  mermaid.initialize({{startOnLoad: false}});
  const source = document.getElementById('source').textContent;
  await mermaid.parse(source);
  const {{svg}} = await mermaid.render('graph', source);
  document.getElementById('diagram').innerHTML = svg;
  status.textContent = 'RENDERED';
}} catch (error) {{
  status.textContent = 'FAILED: ' + error.message;
}}
</script>
"""


def find_browser() -> str:
    candidates = [os.environ["CHROME"]] if os.environ.get("CHROME") else BROWSERS
    for candidate in candidates:
        if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return candidate
        found = shutil.which(candidate)
        if found:
            return found
    sys.exit("No Chromium-based browser found. Set CHROME to the browser binary.")


def run_browser(browser: str, *args: str) -> str:
    command = [browser, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--virtual-time-budget=20000", *args]
    return subprocess.run(command, capture_output=True, text=True, timeout=180).stdout


def check_block(browser: str, block: str, stem: str, out_dir: pathlib.Path) -> tuple[bool, str]:
    page = out_dir / f"{stem}.html"
    page.write_text(PAGE.format(source=html.escape(block), mermaid_url=MERMAID_URL))
    dom = run_browser(browser, "--dump-dom", page.as_uri())
    page_status = re.search(r'<div id="status"[^>]*>(.*?)</div>', dom, flags=re.S)
    status = html.unescape(page_status.group(1)).strip() if page_status else "FAILED: the page did not load"

    if status == "PENDING":
        return False, "NOT RENDERED: Mermaid did not load (no network access?)"
    if status.startswith("FAILED"):
        return False, "PARSE ERROR: " + " ".join(status.removeprefix("FAILED: ").split())[:300]

    view_box = re.search(r'viewBox="[\d.\-]+ [\d.\-]+ ([\d.]+) ([\d.]+)"', dom)
    width, height = (int(float(view_box.group(1))) + 50, int(float(view_box.group(2))) + 70) if view_box else (1400, 1000)
    png = out_dir / f"{stem}.png"
    run_browser(browser, f"--screenshot={png}", f"--window-size={width},{height}", page.as_uri())
    page.unlink()

    bad_labels = sorted(set(re.findall(r"Unsupported markdown: \w+", dom)))
    if bad_labels:
        return False, f"BAD LABEL: {', '.join(bad_labels)}  -> {png}"
    return True, f"OK  {width}x{height} px  -> {png}"


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    source_file, out_dir = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
    blocks = re.findall(r"```mermaid[^\n]*\n(.*?)```", source_file.read_text(), flags=re.S)
    if not blocks:
        sys.exit(f"{source_file}: no mermaid blocks")

    browser = find_browser()
    out_dir.mkdir(parents=True, exist_ok=True)
    all_ok = True
    for number, block in enumerate(blocks, start=1):
        ok, message = check_block(browser, block, f"{source_file.stem}-{number}", out_dir)
        all_ok = all_ok and ok
        print(f"block {number}: {message}")
    sys.exit(0 if all_ok else 1)


if __name__ == "__main__":
    main()
