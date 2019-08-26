#/bin/sh
#remove identical images
#checksum=`convert $1 -colorspace rgb -depth 8 ppm:- | md5sum | tr -d '-'`

#our failure condition will be if a filename has a star in it. It's better than the default one in shell-land, the common space.

IFS='
'

innerPart() {
  for i in `ls -1`
  do
    printf '%s*%s\n' "$i" "`convert $i -depth 8 rgba:- | pixctr`"
  done
}

innerPart | sort --field-separator='*' -nrk 2