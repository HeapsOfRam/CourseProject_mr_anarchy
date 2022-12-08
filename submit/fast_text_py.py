import os
import sys

def main(search_terms):
    fname = "datasets/{}".format("_".join(search_terms)).replace(" ", "_").replace("'", "").replace("#", "")

    print("RUNNING FASTTEXT ON {}".format(fname))
    os.system("./fasttext supervised -input {}-train.txt -output {} -dim 200 -wordNgrams 2 -ws 5".format(fname, fname))
    os.system("./fasttext print-sentence-vectors {}.bin < {}-C1.txt > {}-C1-vec.txt".format(fname, fname, fname))
    os.system("./fasttext print-sentence-vectors {}.bin < {}-C2.txt > {}-C2-vec.txt".format(fname, fname, fname))

if __name__ == "__main__":
    main(sys.argv[1:])
