from pydub import AudioSegment
sound = AudioSegment.from_file("C:/Users/AR064679/Documents/thesis/final R/videoAnalysis/processed/ashwin")

sound.export("C:/Users/AR064679/Documents/thesis/final r/videoAnalysis/processed/", format="mp3", bitrate="128k")