 progidraw=$1
 progid=${progidraw,,}  # Convert to lowercase
 progprefix=${progid:0:4}
 bucket=$(s3cmd ls | grep -o 's3://[^/]*' | head -n 1)
 for geoblock in world no nrk; do
     for client in potion ps; do
         s3cmd ls "$bucket"/assets/"$geoblock"/open/"$client"/"$progprefix"/"$progid"/
     done
 done
