#!/usr/bin/env sh

./build/tools/caffe train -solver models/b3do/solver_rgbd_earlyfusion.prototxt -weights models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel  -iterations 100


