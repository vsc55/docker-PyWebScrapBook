#!/bin/bash

#
# Boot script for WSB daemon.
#
# @version 1.2
# @date 12/07/2026
# @author Javier Pastor
# @license GPL 3.0
#

set -e

FILE_CFG=config.ini
PATH_DATA=/data
PATH_WSB=$PATH_DATA/.wsb
PATH_STORE=$PATH_DATA/store
PATH_CFG=$PATH_WSB/$FILE_CFG
EXEC_WSB=/usr/local/bin/wsb
EXEC_EXTERNAL=$PATH_DATA/run_wsb.sh
APPLY_CFG=/apply_config.py
WSB_USER=wsb

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [boot] $*"; }

# Escape hatch: a run_wsb.sh dropped into the data volume overrides everything.
# exec so it becomes PID 1 and receives Docker signals directly.
if [[ -f $EXEC_EXTERNAL ]]; then
	log "External boot script found ($EXEC_EXTERNAL) — delegating to it."
	exec sh "$EXEC_EXTERNAL"
fi

log "Starting WebScrapBook $("$EXEC_WSB" --version | awk '{print $2}') (port ${HTTP_PORT:-8080})."

log "Ensuring data directories exist under $PATH_DATA..."
mkdir -p "$PATH_DATA" "$PATH_STORE"

first_run=0
if [[ ! -f $PATH_CFG ]]; then
	first_run=1
	log "No config found — generating defaults (config.ini, serve.py, app.py)."
	mkdir -p "$PATH_WSB"
	"$EXEC_WSB" --root "$PATH_DATA" config -ba
else
	log "Existing config found at $PATH_CFG."
fi

# Apply the container environment variables to config.ini on every boot,
# so the environment is the source of truth for the managed keys.
log "Applying environment variables to $PATH_CFG..."
python3 "$APPLY_CFG" "$PATH_CFG"

# WSB_FIX_PERMS=true forces a recursive chown, e.g. to migrate a volume created
# by an older root-based image (set it once, restart, then remove it).
force_chown=0
case "${WSB_FIX_PERMS,,}" in 1|true|on|yes) force_chown=1 ;; esac

if [[ $first_run -eq 1 || $force_chown -eq 1 ]]; then
	# First run (or forced): hand the whole data tree to the unprivileged user.
	[[ $force_chown -eq 1 ]] && reason="WSB_FIX_PERMS" || reason="first run"
	log "Fixing ownership of $PATH_DATA recursively ($reason); this may take a while..."
	chown -R "$WSB_USER:$WSB_USER" "$PATH_DATA"
	log "Ownership fixed."
else
	# Later runs: only ensure the managed paths are writable (fast, no -R).
	log "Ensuring ownership of managed paths for '$WSB_USER' (non-recursive)..."
	chown "$WSB_USER:$WSB_USER" "$PATH_DATA" "$PATH_WSB" "$PATH_STORE" "$PATH_CFG"
fi

# Drop privileges and exec so wsb is PID 1 and shuts down cleanly on SIGTERM.
log "Dropping privileges to '$WSB_USER' and starting the server..."
exec su-exec "$WSB_USER" "$EXEC_WSB" --root "$PATH_DATA" serve
