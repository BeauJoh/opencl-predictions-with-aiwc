#!/usr/bin/env python3

import re                       #for regex
from os import listdir          #for directory listing
from os import makedirs         #for creating directories
from zipfile import ZipFile     #for unzipping

zippy = ZipFile('./aiwc_all.zip','r')
zippy.extractall()
zippy.close()

all_files = listdir(".")
for this_file in all_files:
    if re.match("aiwc_\w+_\w+_0.zip",this_file):
        searcher = re.search("aiwc_(\w+)_(\w+)_0.zip",this_file)
        name = searcher.group(1)
        size = searcher.group(2)

        if name == "gemnoui":
            name = "gem"
        elif name == "openclfft":
            name = "fft"
        elif name == "dwt2d":
            name = "dwt"

        print("extracting " + name +"_" + size)
        output_directory = '../'+name+"_"+size
        makedirs(output_directory,exist_ok=True)
        zippy = ZipFile(this_file,'r')
        zippy.extractall(output_directory)
        zippy.close()

