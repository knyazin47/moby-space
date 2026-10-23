#!/usr/bin/env python3
"""Validate public build configuration before it reaches binaries or manifests."""
from __future__ import annotations

import ipaddress
import os
import re
import sys
from urllib.parse import urlsplit


_ERROR = (
    'Invalid MOBY_API_URL: use an empty value, a root HTTPS URI, or a root '
    'HTTP URI on localhost/127.0.0.1/10.0.2.2, without credentials, query or fragment.'
)
_LOCAL_HTTP_HOSTS = {'localhost', '127.0.0.1', '10.0.2.2'}


def validate_api_url(value: str) -> str:
    """Return the unchanged valid value; error messages never include its bytes."""
    try:
        if not isinstance(value, str):
            raise ValueError
        if not value:
            return value
        if any(character.isspace() or ord(character) < 32 or ord(character) == 127
               for character in value):
            raise ValueError
        uri = urlsplit(value)
        if uri.scheme not in {'https', 'http'} or not uri.netloc:
            raise ValueError
        if '@' in uri.netloc or '?' in value or '#' in value or '\\' in value:
            raise ValueError
        if uri.path not in {'', '/'} or uri.netloc.endswith(':'):
            raise ValueError
        if uri.netloc.startswith('[') and not re.fullmatch(
            r'\[[^\]]+\](?::[0-9]+)?', uri.netloc
        ):
            raise ValueError
        hostname = uri.hostname
        if not hostname:
            raise ValueError
        port = uri.port  # Accessing this property rejects malformed/out-of-range ports.
        if port is not None and not 1 <= port <= 65535:
            raise ValueError
        try:
            ipaddress.ip_address(hostname)
        except ValueError:
            ascii_host = hostname.encode('idna').decode('ascii').removesuffix('.')
            if len(ascii_host) > 253 or not all(
                re.fullmatch(r'[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?', label)
                for label in ascii_host.split('.')
            ):
                raise ValueError
        if uri.scheme == 'http' and hostname not in _LOCAL_HTTP_HOSTS:
            raise ValueError
        return value
    except (ValueError, UnicodeError):
        raise ValueError(_ERROR) from None


if __name__ == '__main__':
    try:
        validate_api_url(os.environ.get('MOBY_API_URL', ''))
    except ValueError as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(2)
