 if [[ $1 == *.mp4 ]]; then
    echo "Cannot preview mediafiles"
else
    FILENAME="/tmp/$(uuidgen)"
    s3cmd get --no-progress -q "$1" "$FILENAME"
    cat "$FILENAME"
    rm "$FILENAME"
fi