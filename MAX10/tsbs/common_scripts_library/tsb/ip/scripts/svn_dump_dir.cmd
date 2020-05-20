#!/bin/bash
REPO_BASE=/cygdrive/f/svn_dumps/
TARGET=/cygdrive/f/svn_dumps_zips/
SVNADMIN=/usr/bin/svnadmin

cd "$REPO_BASE"
for f in *; do
	FILE="$TARGET$f.dump.gz"
	echo "Dump: $f => $FILE"
    test -d "$f"  &&  $SVNADMIN dump "$f" | gzip -9 > "$FILE"
done