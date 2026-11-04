#!/usr/bin/env sh
#
# Test suite for bwgc_vaultwarden.
#
#   ./tests/run-tests.sh            build the image and run every case
#   ./tests/run-tests.sh init       run only cases matching "init"
#   BWGC_IMAGE=... ./tests/run-tests.sh
#
# This image is deprecated in favour of bwgc_backup, and its backup scripts no
# longer change. What can still regress is everything that arrives from the
# moving vaultwarden/server:latest-alpine base on each rebuild: the packages
# the backup depends on, and the entrypoint chain into the base image's own
# /start.sh. These tests cover that surface and no more.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FILTER="${1:-}"

if [ -n "${BWGC_IMAGE:-}" ]; then
	IMAGE="$BWGC_IMAGE"
	printf 'testing existing image: %s\n' "$IMAGE"
else
	IMAGE=bwgc_vaultwarden:test
	printf 'building %s\n' "$IMAGE"
	docker build -q -t "$IMAGE" "$ROOT" >/dev/null
fi

docker run --rm -e FILTER="$FILTER" \
	-v "$ROOT/tests:/tests:ro" \
	-v "$ROOT/scripts/backup_init.sh:/backup_init.sh:ro" \
	-v "$ROOT/scripts/backup.sh:/backup.sh:ro" \
	--entrypoint sh "$IMAGE" /tests/in-container.sh
