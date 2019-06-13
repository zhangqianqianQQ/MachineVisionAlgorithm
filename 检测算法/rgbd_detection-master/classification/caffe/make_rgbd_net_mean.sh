#!/usr/bin/env sh
# Compute the mean image from the imagenet training lmdb
# N.B. this is available in data/ilsvrc12

EXAMPLE=/home/priyanka/caffe/examples/rgb_imagenet/2D3D
DATA=/home/priyanka/caffe/examples/rgb_imagenet/2D3D
TOOLS=build/tools

$TOOLS/compute_image_mean $EXAMPLE/rgb_net_train_lmdb \
  $DATA/rgb_net_mean.binaryproto

echo "RGB mean Done."


$TOOLS/compute_image_mean $EXAMPLE/d_net_train_lmdb \
  $DATA/d_net_mean.binaryproto

echo "RGB mean Done."
