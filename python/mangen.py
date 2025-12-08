#!/usr/bin/env python3
# Example usage:
#   python mangen.py torch --max-depth 2 --exclude-private --out-dir ~/programming/python-man/man3
# Generates man pages for the torch package and its submodules up to depth 2,
#!/usr/bin/env python3
import argparse
import importlib
import pkgutil
import pydoc
import sys
from pathlib import Path
from datetime import date


def is_private_module(name: str) -> bool:
    """
    Consider a module private if *any* segment starts with '_'.
    E.g. torch.ao.pruning._experimental.activation_sparsifier -> private.
    """
    return any(part.startswith("_") for part in name.split("."))


def iter_modules(package_name: str, max_depth: int | None, exclude_private: bool):
    """
    Yield the package itself and its submodules, optionally limited by depth.

    max_depth = 0  -> only the package itself (e.g. 'torch.utils')
    max_depth = 1  -> package + direct children
    max_depth = 2  -> + grandchildren, etc.
    max_depth = None -> no limit.
    """
    try:
        pkg = importlib.import_module(package_name)
    except ImportError as e:
        print(f"Could not import {package_name}: {e}", file=sys.stderr)
        sys.exit(1)

    base_depth = package_name.count(".")

    # Yield the package itself
    if not (exclude_private and is_private_module(pkg.__name__)):
        yield pkg.__name__

    # Not a package? Then we're done.
    if not hasattr(pkg, "__path__"):
        return

    # Walk all submodules (we'll filter by depth and privacy)
    for modinfo in pkgutil.walk_packages(pkg.__path__, pkg.__name__ + "."):
        name = modinfo.name

        # Relative depth compared to the root package
        rel_depth = name.count(".") - base_depth
        if max_depth is not None and rel_depth > max_depth:
            continue

        if exclude_private and is_private_module(name):
            continue

        yield name


def extract_name_and_desc(mod_name: str, plain_text: str):
    """
    Try to extract 'NAME' line from pydoc text so we can feed it into mdoc NAME section.

    pydoc usually has:

        NAME
            torch.nn.functional - Functional interface.
    """
    lines = plain_text.splitlines()
    desc = "Python module"
    for i, line in enumerate(lines):
        if line.strip() == "NAME":
            for j in range(i + 1, len(lines)):
                s = lines[j].strip()
                if not s:
                    continue
                parts = s.split(" - ", 1)
                if len(parts) == 2:
                    if parts[0].strip() == mod_name:
                        desc = parts[1].strip()
                    else:
                        desc = parts[1].strip()
                else:
                    desc = s
                return mod_name, desc
            break
    return mod_name, desc


def pydoc_to_mdoc(mod_name: str, plain_text: str) -> str:
    """
    Wrap the plain pydoc text in a minimal mdoc(7) manpage.
    """
    today = date.today().strftime("%Y-%m-%d")
    upper_name = mod_name.upper()

    nm, desc = extract_name_and_desc(mod_name, plain_text)

    # Indent every line of pydoc so mandoc doesn't try to treat them as macros.
    body_lines = []
    for line in plain_text.splitlines():
        body_lines.append(" " + line)
    body = "\n".join(body_lines)

    mdoc = f""".Dd {today}
.Dt {upper_name} 3
.Os
.Sh NAME
.Nm {nm}
.Nd {desc}
.Sh DESCRIPTION
.Bd -literal
{body}
.Ed
"""
    return mdoc


def main():
    parser = argparse.ArgumentParser(
        description="Generate man pages for a Python package and its submodules."
    )
    parser.add_argument("package", help="Package or module name (e.g. torch or torch.utils)")
    parser.add_argument(
        "-o",
        "--out-dir",
        default="~/programming/python-man/man3",
        help="Output directory for .3 files (default: %(default)s)",
    )
    parser.add_argument(
        "--exclude-private",
        action="store_true",
        help="Skip modules where any path component starts with '_'",
    )
    parser.add_argument(
        "--max-depth",
        type=int,
        default=None,
        help=(
            "Max depth of submodules relative to the given package. "
            "0 = only the package itself, 1 = + direct children, etc. "
            "Default: no limit."
        ),
    )
    parser.add_argument(
        "--top-level-only",
        action="store_true",
        help="Shorthand for --max-depth 0 (only the package itself).",
    )

    fmt_group = parser.add_mutually_exclusive_group()
    fmt_group.add_argument(
        "--plain",
        action="store_true",
        help="Write plain pydoc text (no mandoc wrapper).",
    )
    fmt_group.add_argument(
        "--mdoc",
        action="store_true",
        help="Write mdoc(7)/mandoc-formatted manpages (default).",
    )

    args = parser.parse_args()

    out_dir = Path(args.out_dir).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)

    max_depth = 0 if args.top_level_only else args.max_depth

    # Decide format: default to mdoc if neither flag given
    if args.plain:
        out_format = "plain"
    else:
        out_format = "mdoc"

    for mod_name in iter_modules(args.package, max_depth=max_depth, exclude_private=args.exclude_private):
        print(f"Generating man page for {mod_name}...", file=sys.stderr)
        try:
            raw = pydoc.render_doc(mod_name, "Help on %s")
            plain = pydoc.plain(raw)
            if out_format == "mdoc":
                text = pydoc_to_mdoc(mod_name, plain)
            else:
                text = plain
        except Exception as e:
            print(f"  Skipping {mod_name}: {e}", file=sys.stderr)
            continue

        out_file = out_dir / f"{mod_name}.3"
        out_file.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
