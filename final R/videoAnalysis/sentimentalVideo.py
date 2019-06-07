import os
from pytube import YouTube

# where to save
SAVE_PATH = "C:\\Users\\AR064679\\Documents\\thesis\\final R\\videoAnalysis\\processed\\videos"  # to_do

# link of the video to be downloaded
link = open('C:\\Users\\AR064679\\Documents\\thesis\\final R\\videoAnalysis\\processed\\links.txt',
            'r')  # opening the file

for i in link:
    try:
        # object creation using YouTube which was imported in the beginning
        video_link = 'https://www.youtube.com/watch?v=ibVpDhW6kDQ'
        yt = YouTube(video_link)
        yt.streams.all()
        stream = yt.streams.first()
        print(stream)
        stream.download(SAVE_PATH, filename='ashwin')

    except:
        print("Some Error!")

print('Task Completed!')
