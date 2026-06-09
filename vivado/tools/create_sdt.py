#!/usr/bin/env python3
# =============================================================================
# Copyright (c) 2026 Marco Höfle, Avnet-Silica
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
# =============================================================================

from __future__ import annotations
import vitis
import argparse
import shutil
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a Vitis platform and generate SDT/device-tree artifacts from an XSA."
    )

    parser.add_argument(
        "--xsa",
        required=True,
        help="Input XSA file",
    )
    parser.add_argument(
        "--outdir",
        required=True,
        help="Output workspace directory (will be deleted and recreated unless --no-clean is used)",
    )
    parser.add_argument(
        "--platform-name",
        default="sdt_platform",
        help="Platform component name",
    )
    parser.add_argument(
        "--domain-name",
        default="standalone_microblaze_riscv_0",
        help="Domain name",
    )
    parser.add_argument(
        "--cpu",
        default="mb_system_microblaze_riscv_0",
        help="CPU name, for example psu_cortexa53_0",
    )
    parser.add_argument(
        "--os",
        default="standalone",
        help="OS name, usually linux or standalone",
    )
    parser.add_argument(
        "--generate-dtb",
        action="store_true",
        help="Also generate DTB",
    )
    parser.add_argument(
        "--no-clean",
        action="store_true",
        help="Do not delete outdir before creating workspace",
    )

    return parser.parse_args()


def fail(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def validate_file(path_str: str, description: str) -> Path:
    path = Path(path_str).expanduser().resolve()
    if not path.exists():
        fail(f"{description} does not exist: {path}")
    if not path.is_file():
        fail(f"{description} is not a file: {path}")
    return path


def prepare_output_dir(outdir: Path, clean: bool) -> None:
    if outdir.exists() and clean:
        shutil.rmtree(outdir)
    outdir.mkdir(parents=True, exist_ok=True)


def main() -> int:
    args = parse_args()

    xsa = validate_file(args.xsa, "XSA")
    outdir = Path(args.outdir).expanduser().resolve()

    prepare_output_dir(outdir, clean=not args.no_clean)


    print(f"Using XSA       : {xsa}")
    print(f"Using workspace : {outdir}")

    client = vitis.create_client()
    client.set_workspace(path=str(outdir))

    platform = client.create_platform_component(
        name=args.platform_name,
        hw_design=str(xsa),
        os=args.os,
        cpu=args.cpu,
        domain_name=args.domain_name,
    )



    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
