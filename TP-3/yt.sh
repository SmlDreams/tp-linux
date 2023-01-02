#!/bin/bash
if [[ ! -d '/var/log/yt' ]]; then
    exit 1
fi

if [[ ! -d '/srv/yt/downloads' ]]; then
    echo "Error: downloads/ does not exist"
    exit 1
fi

title="$(youtube-dl --get-filename -o '%(title)s' $1)"
filename="$(youtube-dl --get-filename -o '%(title)s.%(ext)s' $1)"

dest_dir="/srv/yt/downloads/${title}"

if [[ ! -d "${dest_dir}" ]]; then
    mkdir "${dest_dir}"
fi

youtube-dl -o "/srv/yt/downloads/${title}/${filename}" "$1" &> /dev/null
youtube-dl -o "/srv/yt/downloads/${title}/${filename}" --get-description "$1" > "/srv/yt/downloads/${title}/description"
echo "Video $1 was downloaded."
echo "File path : /srv/yt/downloads/${title}/${filename}"
echo "[$(date "+%D %T")] Video $1 was downaloaded. file path : /srv/yt/downloads/${title}/${filename}" > /var/log/yt/download.log 
