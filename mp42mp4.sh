#! /bin/sh
#  last updated : 2020/04/29 22:18:40
#
# re-encode mp4 movie for smaller size with 2 pass encoding
#
CMDNAME=`basename $0`
TMPDIR=`dirname $1`
FFMPEG=/opt/local/bin/ffmpeg
LOG=$TMPDIR/passlog$$
export DYLD_BIND_AT_LAUNCH=1

FIN=$1
if [ ! -f $FIN ] ; then  echo "No such a file: $FIN" ; fi

FOUT="`echo $FIN | cut -f 1 -d .`_lowbps.mp4"

FPS=
if [ $FPS ] ; then FPS="-r $FPS" ; fi

# 映像のビットレート
BPS=50k

# オーディオのビットレート
AUDIOBITRATE=30k

# 画像サイズ
# RESOLUTION="-s 512x384"
#CROP="-cropleft 8 -cropright 8"

THREADS=8
if [ $THREADS ] ; then THREADS="-threads $THREADS" ; fi
echo $THREADS


echo "encoding: $FIN  ===> $FOUT"

QOPT="-qcomp 0.7 -qmin 10 -qmax 51 -qdiff 8"


#    -me_range 32 -sc_threshold 50 -flags loop \

$FFMPEG -y -i $FIN -pass 1 -passlogfile $LOG -vcodec libx264 -level 30 -b:v $BPS $FPS \
    -b_strategy 1  -partitions parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
    $QOPT -me_method umh -subq 7 -trellis 2 -coder ac -g 250 -bf 3 \
    $CROP -sws_flags lanczos $RESOLUTION \
    -me_range 32 -sc_threshold 50 \
    -cmp chroma -refs 5 -ab $AUDIOBITRATE $VOL $AR -async 100 \
    $THREADS \
    $FOUT

$FFMPEG -y -i $FIN -pass 2 -passlogfile $LOG -vcodec libx264 -level 30 -b:v $BPS \
    -b_strategy 1  -partitions parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
    $QOPT -me_method umh -subq 7 -trellis 2 -coder ac -g 250 -bf 3 \
    $CROP -sws_flags lanczos $RESOLUTION \
    -me_range 32 -sc_threshold 50 \
    -cmp chroma -refs 5 -ab $AUDIOBITRATE $VOL $AR -async 100 \
    $THREADS \
    $FOUT

/bin/rm -f ${LOG}*
/bin/rm x264_2pass.log*
exit 0

