#!/usr/bin/env python3
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

SUITE_REPOS = {
    "batten": "0.1.0-beta.2",
    "benchwork": "0.1.0-beta.3",
    "chalkline": "0.1.0-beta.2",
    "dado": "0.1.0-beta.2",
    "joiner": "0.1.0-beta.2",
    "miter": "0.1.0-alpha.3",
    "rabbet": "0.1.0-beta.2",
    "sawhorse": "0.1.0-beta.2",
    "storypole": "0.1.0-beta.2",
}

CRATE_VERSIONS = {
    # batten
    "batten": "0.1.0-beta.2",
    "batten-core": "0.1.0-beta.2",
    "batten-cli": "0.1.0-beta.2",
    "batten-mcp": "0.1.0-beta.2",
    # benchwork
    "benchwork": "0.1.0-beta.3",
    "benchwork-core": "0.1.0-beta.3",
    "benchwork-cli": "0.1.0-beta.3",
    "benchwork-mcp": "0.1.0-beta.3",
    # chalkline
    "chalkline": "0.1.0-beta.2",
    "chalkline-core": "0.1.0-beta.2",
    "chalkline-cli": "0.1.0-beta.2",
    "chalkline-mcp": "0.1.0-beta.2",
    # dado
    "dado": "0.1.0-beta.2",
    "dado-core": "0.1.0-beta.2",
    "dado-cli": "0.1.0-beta.2",
    "dado-mcp": "0.1.0-beta.2",
    # joiner
    "joiner": "0.1.0-beta.2",
    "joiner-core": "0.1.0-beta.2",
    "joiner-cli": "0.1.0-beta.2",
    "joiner-mcp": "0.1.0-beta.2",
    # miter
    "miter": "0.1.0-alpha.3",
    "miter-cli": "0.1.0-alpha.3",
    "miter-ast": "0.1.0-alpha.3",
    "miter-engine": "0.1.0-alpha.3",
    "miter-storage": "0.1.0-alpha.3",
    "miter-harness": "0.1.0-alpha.3",
    "miter-mcp": "0.1.0-alpha.3",
    # rabbet
    "rabbet": "0.1.0-beta.2",
    "rabbet-core": "0.1.0-beta.2",
    "rabbet-cli": "0.1.0-beta.2",
    # sawhorse
    "sawhorse": "0.1.0-beta.2",
    "sawhorse-core": "0.1.0-beta.2",
    "sawhorse-cli": "0.1.0-beta.2",
    # storypole
    "storypole": "0.1.0-beta.2",
    "storypole-core": "0.1.0-beta.2",
    "storypole-cli": "0.1.0-beta.2",
    "storypole-mcp": "0.1.0-beta.2",
}

def update_cargo_toml(path: Path, repo_name: str, target_ver: str):
    content = path.read_text()
    orig = content

    # 1. Update [workspace.package] version = "..."
    content = re.sub(
        r'(\[workspace\.package\]\s*\n(?:[^\n]*\n)*?version\s*=\s*)"[^"]+"',
        rf'\g<1>"{target_ver}"',
        content,
    )

    # 2. Update dependencies pointing to any suite crate
    for crate, ver in CRATE_VERSIONS.items():
        # Match inline table: crate = { ... version = "..." ... }
        content = re.sub(
            rf'(^{re.escape(crate)}\s*=\s*\{{[^}}]*version\s*=\s*)"[^"]+"([^}}]*\}})',
            rf'\g<1>"{ver}"\g<2>',
            content,
            flags=re.MULTILINE,
        )
        # Match string version: crate = "0.1.0-..."
        content = re.sub(
            rf'(^{re.escape(crate)}\s*=\s*)"(?:0\.1\.0-(?:beta|alpha)\.\d+)"',
            rf'\g<1>"{ver}"',
            content,
            flags=re.MULTILINE,
        )

    if content != orig:
        path.write_text(content)
        print(f"Updated {path.relative_to(ROOT)}")

def main():
    print("Bumping suite versions...")
    for repo, ver in SUITE_REPOS.items():
        repo_dir = ROOT / repo
        for toml_path in repo_dir.rglob("Cargo.toml"):
            if "target" in toml_path.parts:
                continue
            update_cargo_toml(toml_path, repo, ver)

    # Benchwork web package.json
    pkg_json = ROOT / "benchwork" / "web" / "package.json"
    if pkg_json.exists():
        content = pkg_json.read_text()
        content = re.sub(r'("version":\s*)"[^"]+"', r'\g<1>"0.1.0-beta.3"', content)
        pkg_json.write_text(content)
        print("Updated benchwork/web/package.json")

if __name__ == "__main__":
    main()

