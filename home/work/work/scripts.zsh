play_tv () {
    curl -s https://psapi.nrk.no/playback/manifest/program/$1 | jq -r '.playable.assets[0].url' | cut -d'?' -f1 | xargs mpv
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

play_two () {
    mpv $1 --external-file=$2 --lavfi-complex='[vid1] [vid2] hstack [vo]'
}

find_potion () {
    curl -s "https://origo-service-discovery.kubeint.nrk.no/rule?url=$1" | jq '.links.[] | select(.rel=="potion-meo-details").href' | xargs firefox -new-tab
}