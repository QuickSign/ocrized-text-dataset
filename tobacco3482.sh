#!/bin/bash
FOLDER=datasets/Tobacco3482/
mkdir -p "${FOLDER}" && cd "${FOLDER}"
echo "Downloading files from UMIACS server..."
wget -nv --show-progress -c http://lampsrv02.umiacs.umd.edu/projdb/edit/userfiles/datasets/Tobacco3482_1.zip
wget -nv --show-progress -c http://lampsrv02.umiacs.umd.edu/projdb/edit/userfiles/datasets/Tobacco3482_2.zip
echo "Decompressing .zip archives..."
unzip -n 'Tobacco3482_*.zip'
echo "Generating filelist"
find . -name '*.tif' > images.txt
read -p "Do you want to run the OCR script now? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    python ../../to_text.py images.txt --lang eng --format txt
else
    echo
fi
sed 's/\.tif/.txt/g' < images.txt > texts.txt