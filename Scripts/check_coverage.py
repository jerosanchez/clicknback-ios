#!/usr/bin/env python3
"""
Scripts/check_coverage.py

Finds the latest xcresult bundle produced by `make test`, extracts line
coverage for the app target via `xcrun xccov`, and prints a formatted report.

Usage:
    python3 Scripts/check_coverage.py [minimum_coverage]

Exit codes:
    0 — coverage meets or exceeds the minimum
    1 — coverage is below the minimum, or no data was found
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Optional

# ── Constants ─────────────────────────────────────────────────────────────────

LOGS_DIR  = "build/Logs/Test"
BAR_WIDTH = 40

# Files excluded from coverage measurement.
# Rationale:
#   - Derived/Sources/  — Tuist-generated asset/bundle accessors; not authored code
#   - Support/Preview/  — Xcode canvas helpers; never executed in production or tests
EXCLUDED_PATH_FRAGMENTS = [
    "/Derived/Sources/",
    "/Support/Preview/",
]

RESET  = "\033[0m"
BOLD   = "\033[1m"
GREEN  = "\033[32m"
YELLOW = "\033[33m"
RED    = "\033[31m"
CYAN   = "\033[36m"

SEP = f"{BOLD}{CYAN}  {'━' * 44}{RESET}"


# ── Helpers ───────────────────────────────────────────────────────────────────

def find_latest_xcresult(logs_dir: str) -> Optional[Path]:
    """Return the most recently modified xcresult bundle, or None."""
    bundles = sorted(
        Path(logs_dir).glob("*.xcresult"),
        key=lambda p: p.stat().st_mtime,
    )
    return bundles[-1] if bundles else None


def load_coverage_json(bundle: Path) -> dict:
    """Run xcrun xccov and return parsed JSON, or raise on failure."""
    result = subprocess.run(
        ["xcrun", "xccov", "view", "--report", "--json", str(bundle)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or not result.stdout.strip():
        raise RuntimeError(
            f"xccov returned no data for: {bundle.name}\n"
            "Make sure 'Gather coverage' is enabled in the scheme."
        )
    return json.loads(result.stdout)


def is_excluded(file_path: str) -> bool:
    """Return True if the file should be omitted from coverage measurement."""
    return any(fragment in file_path for fragment in EXCLUDED_PATH_FRAGMENTS)


def compute_coverage(data: dict) -> float:
    """
    Compute line coverage percentage for app targets only, excluding:
    - *Tests and *UITests bundles that appear in the xccov report
    - Files matched by EXCLUDED_PATH_FRAGMENTS (generated code, preview helpers)
    """
    targets = data.get("targets", [])
    app_targets = [
        t for t in targets
        if "Tests" not in t.get("name", "") and "UITests" not in t.get("name", "")
    ]
    if app_targets:
        total = covered = 0
        for t in app_targets:
            for f in t.get("files", []):
                if is_excluded(f.get("path", "")):
                    continue
                total   += f.get("executableLines", 0)
                covered += f.get("coveredLines",    0)
        return (covered / total * 100) if total > 0 else 0.0
    # Fall back to the top-level lineCoverage field (0.0–1.0 scale)
    return data.get("lineCoverage", 0.0) * 100


def tier(coverage: float, minimum: float) -> tuple[str, str, str]:
    """Return (emoji, label, color) for the given coverage value."""
    if coverage >= 75:
        return "🚀", "Exceeds expectations", GREEN
    if coverage >= minimum:
        return "✅", "Passed", GREEN
    if coverage >= 60:
        return "⚠️ ", "Almost there", YELLOW
    return "❌", "Poor", RED


def progress_bar(coverage: float, color: str) -> str:
    filled = int(coverage / 100 * BAR_WIDTH)
    bar    = "█" * filled + "░" * (BAR_WIDTH - filled)
    return f"[{color}{bar}{RESET}]"


def print_report(coverage: float, minimum: float) -> None:
    emoji, label, color = tier(coverage, minimum)
    diff  = coverage - minimum
    arrow = "▲" if diff >= 0 else "▼"
    note  = (
        f"{diff:.1f}pp above the {minimum:.0f}% minimum"
        if diff >= 0
        else f"{abs(diff):.1f}pp below the {minimum:.0f}% minimum — add more tests"
    )

    print()
    print(SEP)
    print("    📊  Code Coverage Report")
    print(SEP)
    print()
    print(f"  Coverage   {color}{BOLD}{coverage:.1f}%{RESET}")
    print(f"  Minimum    {minimum:.0f}%")
    print(f"  Status     {emoji}  {color}{BOLD}{label}{RESET}")
    print()
    print(f"  {progress_bar(coverage, color)}")
    print()
    print(f"  {arrow}  {coverage:.1f}% — {note}")
    print()
    print(SEP)
    print()


# ── Entry point ───────────────────────────────────────────────────────────────

def main() -> int:
    minimum = float(sys.argv[1]) if len(sys.argv) > 1 else 65.0

    bundle = find_latest_xcresult(LOGS_DIR)
    if bundle is None:
        print()
        print(f"  ❌  No test results found in '{LOGS_DIR}'.")
        print("  Run 'make test' first, then re-run 'make coverage'.")
        print()
        return 1

    try:
        data     = load_coverage_json(bundle)
        coverage = compute_coverage(data)
    except (RuntimeError, json.JSONDecodeError, KeyError) as exc:
        print()
        print(f"  ❌  {exc}")
        print()
        return 1

    print_report(coverage, minimum)
    return 0 if coverage >= minimum else 1


if __name__ == "__main__":
    sys.exit(main())
