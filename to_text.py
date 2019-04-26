"""
Convert a list of images to text using Tesseract OCR.
Author: nicolas.audebert@quicksign.com
"""
import argparse
import os
import pytesseract

from builtins import str
from joblib import Parallel, delayed
from PIL import Image
from tqdm import tqdm

parser = argparse.ArgumentParser()
parser.add_argument("file", type=str, help="Path to the file containing the list of docs to OCR")
parser.add_argument(
    "--lang",
    type=str,
    default="eng",
    help="Language to use for Tesseract, e.g. fra, eng, ger, ... (default=eng)",
)
parser.add_argument(
    "--jobs", type=int, default=1, help="Number of parallel jobs to run (default=1)"
)
parser.add_argument(
    "--format",
    type=str,
    default="txt",
    help="Output Tesseract format, either .txt or .hocr (default=.txt)",
)
parser.add_argument("--noerror", action="store_true", default=False, help="Ignore errors.")


def to_text(filename, lang="eng", format_="txt", ignore_error=False):
    """ Extract text from an image using Tesseract OCR.

    Arguments:
        filename {str} -- path to an image

    Keyword Arguments:
        lang {str} -- Tesseract OCR language option (default: "eng")
        format_ {str} -- Tesseract output format (.hocr or .txt, default: "txt")
        ignore_error {bool} -- catch and ignore all exceptions (default: False)
    """
    try:
        im = Image.open(filename)
        basename, ext = os.path.splitext(filename)
        target = basename + "." + format_
        if format_ == "txt":
            tess_output = pytesseract.image_to_string(im, lang=lang, config="--psm 3 --oem 1")
        elif format_ == "hocr":
            tess_output = pytesseract.image_to_pdf_or_hocr(
                im, lang=lang, config="--psm 3 --oem 1", extension=format_
            )
        with open(target, "w") as fp:
            fp.write(str(tess_output))
    except Exception as e:
        if ignore_error:
            print("Error: {}".format(e))
        else:
            raise e


if __name__ == "__main__":
    args = parser.parse_args()
    with open(args.file, "r") as f:
        dirname = os.path.dirname(args.file)
        filenames = map(str.strip, f.readlines())
        filenames = list(map(lambda path: os.path.join(dirname, path), filenames))
    Parallel(n_jobs=args.jobs)(
        delayed(to_text)(filename, lang=args.lang, format_=args.format, ignore_error=args.noerror)
        for filename in tqdm(filenames)
    )
