#! /bin/bash

# only the CAPITALIZED variables below are changable!

VBR="2500K"                                 						# Bitrate
BUFSIZE="5000K"										# Buffer size (2 times the bitrate)
FPS="30"                                    						# FPS
YOUTUBE_URL="rtmp://a.rtmp.youtube.com/live2"						# YouTube RTMP server URL

FOLDER="/mnt/f/torrent/Armin_van_Buuren_A_State_of_Trance_001-499"			# Folder to stream from
KEY="your-stream-key-here"								# YouTube Stream Key

stream_name=""
files=($FOLDER/*.mp3);
f="${files[RANDOM % ${#files[@]}]}"

stream_name="A State Of Trance Episode ${f: -7}"
stream_name="${stream_name%.*}"
ep_num="${stream_name: -4}"
echo $stream_name
echo "Fetching details for episode $ep_num"
php asottrackfetcher.php $ep_num
echo "Details fetched"
ffmpeg \
	-i "$f" -i "asot_bg.jpg" -filter_complex "[0:a]showwaves=s=nhd:mode=cline:colors=White@1|White@1, colorkey=color=black:similarity=0.2, realtime[vis]; [vis]format=argb, colorchannelmixer=aa=0.2, scale=1280:480[visalpha]; [1:v][visalpha]overlay=x=0:y=260[visdone]; [visdone]drawtext=text='Currently playing\: $stream_name':fontcolor=White@1:fontsize=30:font=Roboto:shadowx=1:shadowy=1:x=20:y=20, drawtext=textfile=asotdata.txt:font=Roboto:text_shaping=1:fix_bounds=true:fontcolor=White@1:fontsize=20:expansion=none:shadowx=1:shadowy=1:x=20:y=64, drawtext=text='%{pts\:gmtime\:0\:%H\\\\\:%M\\\\\:%S}':fontcolor=0xA3A3A3:fontsize=16:font=monospace:shadowx=1:shadowy=1:x=20:y=h-th-20, drawtext=text='A State Of Trance Episodes 24/7 (unofficial stream)':fontcolor=White@1:fontsize=20:font=Roboto:shadowx=1:shadowy=1:x=20:y=h-th-36, colorkey=color=black:similarity=0.2[out]" \
	-map "[out]" -map 0:a -deinterlace \
	-c:v libx264 -x264-params "nal-hrd=cbr" -pix_fmt yuv420p -g $(($FPS * 2)) -b:v $VBR -framerate 30 -maxrate $BUFSIZE -bufsize $BUFSIZE \
	-c:a aac -ar 44100 -b:a 192k \
	-threads 6 -movflags +faststart -f flv "$YOUTUBE_URL/$KEY"

./streamsingle.sh
