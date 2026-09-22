#!/usr/bin/env python3
"""Build this checkout with --backend cuda or cumetal; --install is explicit."""
import sys

# A read-only --check/--dry-run must not even create Python bytecode caches.
sys.dont_write_bytecode = True

from destruction_build import main

if __name__ == '__main__':
    raise SystemExit(main())
