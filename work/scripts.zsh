play_tv () {
    curl -s https://psapi.nrk.no/playback/manifest/program/$1 | jq -r '.playable.assets[0].url' | cut -d'?' -f1 | xargs mpv
}

s3find () {
    progidraw=$1
    progid=${progidraw:l}
    progprefix=${progid:0:4}

    bucket=$(s3cmd ls | grep -o 's3://[^/]*' | head -n 1)

    for geoblock in world no nrk; do
        for client in potion ps; do
        s3cmd ls ${bucket}/assets/${geoblock}/open/${client}/${progprefix}/${progid}/
        done
    done
}

s3cat () {
    s3path=$(s3find $1 | sort -r | awk '{print $4}' | fzf --disabled --no-sort --preview 's3preview {}')
    output=$(uuidgen)
    outpath=/tmp/$output
    s3cmd get $s3path $outpath
    if [[ $s3path == *.mp4 ]]; then
        mpv $outpath
    else
        cat $outpath
    fi
}