# asot_streamer_youtube
A script which streams all mp3 files in a folder to YouTube with a simple visualizer and tracklist. This script was specifically written with the radio show "[A State Of Trance](http://www.astateoftrance.com/)" in mind. YouTube bans the stream within a few hours, so I never actually used it in the end. I knew this was going to happen - I just wanted to test if what I had in mind was possible.

## What I tried to do
I tried streaming all episodes from a radio show, recorded in MP3 format, to YouTube. However, I didn't want to include just a static image as the video stream, so I implemented a simple visualization using ffmpeg. Then I added a script to fetch the tracklist from the official radio show website, which then gets displayed in the video stream as well.

## What can you do with this?
Use this as an inspiration I guess!

## How can I modify the code for my own project?
I have no idea. What I can do though, is go through how my code works. Here we go.

### streamsingle.sh
This is the main script file, which you should run to start the stream. A few variables are set in the beginning, such as the bitrate, the fps, the livestreaming server URL of YouTube, the folder containing all MP3 files, and of course your YouTube account's stream key.

On line 15, a random MP3 file from the folder gets selected to stream. The stream name gets changed into the episode number of that episode (which is specified in the filename at position -7 from the end of the filename string). Then, we're now on line 22, a PHP executable gets called which will fetch the tracklist. I will explain this file below.

On line 24, the command which gets the stream going gets run - ffmpeg! This command is long as f\*ck, so bear with me. First, we set the input files - the MP3 file set in the variable "f" earlier, and a background image, which is asot_bg.jpg. This image has the dimensions in which we want to stream (currently 720p, so the file is 1280 by 720 pixels). Then, a very complex filter gets added. It basically adds the visualization. I cannot explain it fully. In this filter, the tracklist also gets added using the drawtext function of ffmpeg's complex_filter parameter. A piece of text showing the current time also gets added to the video stream here, as well as a piece of text ("A State Of Trance Episodes 24/7 (unofficial stream)"). Feel free to edit this text, of course.

After this filter stuff, we make sure the audio remains the same - we just map it to position 0 in the output. Then we add some more stuff YouTube requires for their livestream formats (such as the libx254 video codec, yuv420p pixel format, the buffer size, the bitrate, the aac audio codec, et cetera). Finally, we set the output to be in flv format, which we send to the YouTube livestreaming server.

The ffmpeg command will keep running until it has finished playing the full MP3 file. Once it's done, it will continue on to line 31, where this same file gets called, which creates an infinite loop to make sure the stream keeps going!

### asottrackfetcher.php
**This file is specifically used for the radio show A State Of Trance and does not work for other radio shows or whatever out of the box. I'll just explain the code so you *could* modify and use it, if you wanted to.**

This file retrieves the tracklist from the current radio show episode. It gets called with one argument, being the episode number. We retrieve the webpage for that episode, set an initial tracklist string ("No tracklist available"), then load the webpage into PHP's DOMDocument class, which makes us able to browse through a parsed version of the HTML like we normally do in Javascript. First we find the "main" HTML tag, as this one defines where the main part of the webpage begins.

Line 13: we find the h1 tag, which defines the start of the "article" on the current episode. We then go to the next sibling and find it's text content, which is the episode's name. Then, on the next line, we add two line breaks.

On line 15 we look for an unordered list in HTML on the webpage, which contains the tracklist. If it is found, we loop through the items in that list and add each of its text contents to our tracklist. If it is not present, the tracklist is not in HTML format, then it's just a piece of text. If so, we just add that piece of text to our tracklist.

On the final line, we write the tracklist to a file called "asotdata.txt", which gets added to the stream in streamsingle.sh!

#### Why use PHP for this? PHP sucks.
I used PHP for this because it's one of the languages I understand well enough to write something like this. It just does the job, on the server-side. If you think it sucks, just use something else I guess! No hard feelings.
