#! /bin/bash

# only the CAPITALIZED variables below are changable!

VBR="2500K"                                 								# Bitrate
BUFSIZE="5000K"																# Buffer size (2 times the bitrate)
FPS="30"                                    								# FPS

FILE="/mnt/e/coding/asot_streamer_youtube/in.mp3"							# File to read
OUT="/mnt/e/coding/asot_streamer_youtube/out.flv"							# Output

ffmpeg \
	-i "$FILE" -i "asot_bg.jpg" -filter_complex "[0:a]showwaves=s=nhd:mode=cline:colors=White@1|White@1, colorkey=color=black:similarity=0.2, realtime[vis]; [vis]format=argb, colorchannelmixer=aa=0.2, scale=1280:480[visalpha]; [1:v][visalpha]overlay=x=0:y=260[out]" \
	-map "[out]" -map 0:a -deinterlace \
	-c:v libx264 -x264-params "nal-hrd=cbr" -pix_fmt yuv420p -g $(($FPS * 2)) -b:v $VBR -framerate 30 -maxrate $BUFSIZE -bufsize $BUFSIZE \
	-c:a aac -ar 44100 -b:a 192k \
	-threads 6 -movflags +faststart -f flv "$OUT"