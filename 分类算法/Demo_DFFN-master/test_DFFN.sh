#!/usr/bin/env sh
set -e
./caffe-master/build/tools/caffe test --model=./prototxt_files/test_indian_pines.prototxt --weights=./snapshot/indian_pines/_iter_20000.caffemodel -iterations=461 -gpu=0   # for the Indian Pines image

#./caffe-master/build/tools/caffe test --model=./prototxt_files/test_paviau.prototxt --weights=./snapshot/paviau/_iter_20000.caffemodel -iterations=2096 -gpu=0   # for the University of Pavia image

#./caffe-master/build/tools/caffe test --model=./prototxt_files/test_salinas.prototxt --weights=./snapshot/salinas/_iter_20000.caffemodel -iterations=1077 -gpu=0   # for the Salinas image
