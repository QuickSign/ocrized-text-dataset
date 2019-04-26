#!/bin/bash

FILELIST=images/filelist.txt

wget_from_gdrive() {
    # This is a helper function to download files from Google Drive despite the annoying
    # "file to large to scan" antivirus warning.
    TMP_COOKIES=/tmp/cookies.txt
    CONFIRM_FILE=/tmp/confirm.txt
    fileid="$1"
    filename="$2"
    wget -q --save-cookies "${TMP_COOKIES}" 'https://docs.google.com/uc?export=download&id='$fileid -O- \
         | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > "${CONFIRM_FILE}"

    wget -nv --show-progress -c --load-cookies "${TMP_COOKIES}" -O "$filename" \
        'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<"${CONFIRM_FILE}")
    
    rm "${TMP_COOKIES}"
}

FOLDER=datasets/rvl-cdip/
mkdir -p "${FOLDER}" && cd "${FOLDER}"
echo "Downloading files from Google Drive..."
wget_from_gdrive "0B0NKIRwUL9KYcXo3bV9LU0t3SGs" labels.tar.gz
wget_from_gdrive "0Bz1dfcnrpXM-MUt4cHNzUEFXcmc" images.tar.gz
echo "Extracting archives..."
tar xvzf labels.tar.gz
echo "Generating filelist"
cat labels/{train,val,test}.txt | cut -d ' ' -f 1 > "${FILELIST}"
for file in train.txt val.txt test.txt; do
    sed 's/\.tif/.txt/g' < "${file}" > "text_${file}.txt"
done
read -p "Do you want to run the OCR script now? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    python ../../to_text.py "${FILELIST}" --lang eng --format txt
else
    echo
fi