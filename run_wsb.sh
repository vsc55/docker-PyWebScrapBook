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

# Escape hatch: a run_wsb.sh dropped into the data volume overrides everything.
# exec so it becomes PID 1 and receives Docker signals directly.
if [[ -f $EXEC_EXTERNAL ]]; then
	echo "*** RUN EXTERNAL ***"
	exec sh "$EXEC_EXTERNAL"
fi

echo "Starting webscrapbook $("$EXEC_WSB" --version | awk '{print $2}')..."

mkdir -p "$PATH_DATA" "$PATH_STORE"

first_run=0
if [[ ! -f $PATH_CFG ]]; then
	first_run=1
	mkdir -p "$PATH_WSB"
	"$EXEC_WSB" --root "$PATH_DATA" config -ba
fi

# Apply the container environment variables to config.ini on every boot,
# so the environment is the source of truth for the managed keys.
python3 "$APPLY_CFG" "$PATH_CFG"

if [[ $first_run -eq 1 ]]; then
	# First run: hand the whole data tree to the unprivileged user.
	chown -R "$WSB_USER:$WSB_USER" "$PATH_DATA"
else
	# Later runs: only ensure the managed paths are writable (fast, no -R).
	chown "$WSB_USER:$WSB_USER" "$PATH_DATA" "$PATH_WSB" "$PATH_STORE" "$PATH_CFG"
fi

# Drop privileges and exec so wsb is PID 1 and shuts down cleanly on SIGTERM.
exec su-exec "$WSB_USER" "$EXEC_WSB" --root "$PATH_DATA" serve
