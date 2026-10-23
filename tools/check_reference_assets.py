#!/usr/bin/env python3
"""Compatibility entrypoint; use tools/check_assets.py for the full build gate."""
from check_assets import main

if __name__ == "__main__":
    raise SystemExit(main())
