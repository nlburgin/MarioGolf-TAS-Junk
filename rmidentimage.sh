#/bin/sh
#remove identical images
#checksum=`convert $1 -colorspace rgb -depth 8 ppm:- | md5sum | tr -d '-'`

IFS='
'
innerPart() {
  checksum=`crccheck <"$1"`
  for i in `ls -1`
  do
    #if [ `convert $i -colorspace rgb -depth 8 ppm:- | md5sum | tr -d '-'` = $checksum ]
    if [ `crccheck <"$i"` = $checksum ]
    then
      rm $i
    fi
  done
}

otherDir="../`basename $PWD`2"

mkdir $otherDir

for i in `ls -1`
do 
  mv "$i" $otherDir/"$i"
  innerPart $otherDir/"$i"
done