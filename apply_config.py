#!/usr/bin/env python3
"""Apply Docker environment variables to a WebScrapBook config.ini.

The managed keys below are (re)written on every container boot, so the
container environment is the source of truth for them. Optional keys are only
touched when their environment variable is set; the ``[auth "docker"]`` section
is fully managed (created when WSB_AUTH_USER is set, removed otherwise).

Comments in the file are not preserved (configparser limitation); run
``wsb help config`` for the documented reference of every option.

Usage: apply_config.py <path-to-config.ini>
"""
import os
import sys
from configparser import ConfigParser

from werkzeug.security import check_password_hash, generate_password_hash

AUTH_SECTION = 'auth "docker"'

# Container essentials: always enforced -> (section, key, value)
BASE = [
    ('app', 'root', './store/'),
    ('server', 'host', '0.0.0.0'),
    ('server', 'port', os.environ.get('HTTP_PORT', '8080')),
    ('server', 'browse', 'false'),
]

# Optional: applied only when the environment variable is present.
# env var -> (section, key)
OPTIONAL = {
    'WSB_APP_NAME': ('app', 'name'),
    'WSB_THEME': ('app', 'theme'),
    'WSB_LOCALE': ('app', 'locale'),
    'WSB_ALLOWED_X_FOR': ('app', 'allowed_x_for'),
    'WSB_ALLOWED_X_PROTO': ('app', 'allowed_x_proto'),
    'WSB_ALLOWED_X_HOST': ('app', 'allowed_x_host'),
    'WSB_ALLOWED_X_PORT': ('app', 'allowed_x_port'),
    'WSB_ALLOWED_X_PREFIX': ('app', 'allowed_x_prefix'),
    'WSB_SSL_ON': ('server', 'ssl_on'),
    'WSB_SSL_CERT': ('server', 'ssl_cert'),
    'WSB_SSL_KEY': ('server', 'ssl_key'),
    'WSB_SSL_PW': ('server', 'ssl_pw'),
}


def ensure(cp, section):
    if not cp.has_section(section):
        cp.add_section(section)


def apply_auth(cp):
    """Manage the [auth "docker"] section from WSB_AUTH_* variables."""
    user = os.environ.get('WSB_AUTH_USER')
    if not user:
        # No user configured -> make sure our managed rule is gone.
        if cp.has_section(AUTH_SECTION):
            cp.remove_section(AUTH_SECTION)
        return

    password = os.environ.get('WSB_AUTH_PASSWORD', '')
    permission = os.environ.get('WSB_AUTH_PERMISSION', 'all')

    ensure(cp, AUTH_SECTION)
    cp[AUTH_SECTION]['user'] = user
    cp[AUTH_SECTION]['permission'] = permission

    # Re-hash only when the password actually changed, to avoid rewriting a
    # fresh salt (and thus churning the file) on every boot.
    current = cp[AUTH_SECTION].get('pw', '')
    if password == '':
        cp[AUTH_SECTION]['pw'] = ''
    elif not (current and check_password_hash(current, password)):
        cp[AUTH_SECTION]['pw'] = generate_password_hash(password)


def main():
    if len(sys.argv) != 2:
        sys.exit('usage: apply_config.py <path-to-config.ini>')
    path = sys.argv[1]

    # interpolation=None so a literal '%' in a value (e.g. WSB_APP_NAME) does
    # not raise on the next read; optionxform=str preserves key case.
    cp = ConfigParser(interpolation=None)
    cp.optionxform = str
    cp.read(path, encoding='utf-8')

    for section, key, value in BASE:
        ensure(cp, section)
        cp[section][key] = value

    for env, (section, key) in OPTIONAL.items():
        if env in os.environ:
            ensure(cp, section)
            cp[section][key] = os.environ[env]

    apply_auth(cp)

    with open(path, 'w', encoding='utf-8') as fh:
        fh.write('; Managed by docker-PyWebScrapBook: the keys below are applied from\n')
        fh.write('; container environment variables on every boot. Run "wsb help config"\n')
        fh.write('; for the full reference of available options.\n\n')
        cp.write(fh)


if __name__ == '__main__':
    main()
