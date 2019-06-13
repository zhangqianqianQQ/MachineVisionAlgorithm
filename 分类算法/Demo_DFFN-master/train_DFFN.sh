#!/usr/bin/env sh
set -e

./caffe-master/build/tools/caffe train --solver=./prototxt_files/solver_indian_pines.prototxt $@  # for training the DFFN on the Indian Pines image

#./caffe-master/build/tools/caffe train --solver=./prototxt_files/solver_paviau.prototxt $@  # for training the DFFN on the University of Pavia image

#./caffe-master/build/tools/caffe train --solver=./prototxt_files/solver_salinas.prototxt $@  # for training the DFFN on the Salinas image
