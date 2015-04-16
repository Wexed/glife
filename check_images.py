import io
import os
import re

path = os.getcwd()
print path

startpattern = """images/"""
imgFormats = ['jpg','gif']

infile = io.open('glife.txt',mode='r',encoding='utf-16')
lines = infile.readlines()

images = []

for line in lines:
    for fmt in imgFormats:
        if fmt in line:
            imgs = re.findall(startpattern + '.*\.' + fmt, line)
            for img in imgs:
                images.append(img)

for image in images:
    if not os.path.isfile(os.path.join(path, image)):
        print "Image not found:", image
