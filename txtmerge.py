#!/usr/bin/env python
# usage: txtmerge.py <input_dir> <output_file_name> 
# does the exact opposite of txtsplit.py

import os
import sys
import re
import io

assert len(sys.argv) == 3, "usage:\ntxtmerge.py <input_dir> <output_file_name>"
idir = str(sys.argv[1])
oname = str(sys.argv[2])

ofile = io.open(oname, 'w', encoding='utf-16', newline='\r\n')

for iname in os.listdir( idir ):
    ifile = io.open(os.path.join(idir,iname), 'rt', encoding='utf-8')
    text = ifile.read()
    ofile.write(text)
    ifile.close()

ofile.close()
    
        
