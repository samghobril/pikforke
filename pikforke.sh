#!/bin/bash

grepFromUrl() {
    if [ "$1" = "-u" ]; then
	    curl -s $2 | hxpipe | grep -m 1 -B $4 -A $5 "$3"
    else
	    curl -s $1 | hxpipe | grep -B $3 -A $4 "$2"
    fi
	
}


if [ $# -lt 1 ] 
then
    read -p 'Artist: ' artist
    
else
    artist=$1
fi
encodedArtist=${artist// /%20}
url="http://pitchfork.com/search/?query=$encodedArtist"
artistUrl=$(grepFromUrl -u $url "artist-name" 7 0 | grep Ahref | grep -o "\/.*")
if [ -z "$artistUrl" ]
then
      echo "No reviews found for $artist on Pitchfork."
      exit
fi
fullUrl="http://pitchfork.com$artistUrl"
albums=$(grepFromUrl $fullUrl "/reviews/albums/[0-9]" 1 1| grep -o "\/.*")
for album in $albums
do
    fullUrl="http://pitchfork.com$album"
    name=$(grepFromUrl $fullUrl "Aclass CDATA review-title$" 0 4 | grep "^\-")
    name=${name:1}
    score=$(grepFromUrl $fullUrl "Aclass CDATA score$" 0 4 | grep "^\-")
    score=${score:1}
    echo "$name    $score"
done