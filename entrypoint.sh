#!/bin/bash
set -e

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [entrypoint] $*"; }

CMD=${@:1:1}

case "$CMD" in
	"" )
		log "No command given (CMD is empty)."
		exit 1
		;;
	"start" )
		log "Command 'start' — launching the boot script."
		exec /run_wsb.sh
		;;
	* )
		# Run custom command. Thanks to this line we can still use
		# "docker run our_image /bin/bash" and it will work.
		# Log only the command name, not its arguments (they may carry secrets).
		log "Running custom command: $CMD"
		exec "$@"
		;;
esac
