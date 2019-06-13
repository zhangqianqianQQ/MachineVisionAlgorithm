#!/usr/bin/env sh
# Create the imagenet lmdb inputs
# N.B. set the path to the imagenet train + val data dirs

##########
EXAMPLE=/home/priyanka/caffe/examples/rgb_imagenet/2D3D
DATA=/home/priyanka/caffe/examples/rgb_imagenet/2D3D
TOOLS=build/tools

############
TRAIN_DATA_ROOT_RGB=/home/priyanka/caffe/examples/rgb_imagenet/2D3D/rgb
VAL_DATA_ROOT_RGB=/home/priyanka/caffe/examples/rgb_imagenet/2D3D/rgb

TRAIN_DATA_ROOT_D=/home/priyanka/caffe/examples/rgb_imagenet/2D3D/dcolor
VAL_DATA_ROOT_D=/home/priyanka/caffe/examples/rgb_imagenet/2D3D/dcolor
############

# Set RESIZE=true to resize the images to 256x256. Leave as false if images have
# already been resized using another tool.
RESIZE=true
if $RESIZE; then
  RESIZE_HEIGHT=256
  RESIZE_WIDTH=256
else
  RESIZE_HEIGHT=0
  RESIZE_WIDTH=0
fi
echo "********$BACKEND"


echo "********$BACKEND"
if [ ! -d "$TRAIN_DATA_ROOT_RGB" ]; then
  echo "Error: TRAIN_DATA_ROOT is not a path to a directory: $TRAIN_DATA_ROOT_RGB"
  echo "Set the TRAIN_DATA_ROOT variable in create_imagenet.sh to the path" \
       "where the ImageNet training data is stored."
  exit 1
fi

if [ ! -d "$VAL_DATA_ROOT_RGB" ]; then
  echo "Error: VAL_DATA_ROOT is not a path to a directory: $VAL_DATA_ROOT_RGB"
  echo "Set the VAL_DATA_ROOT variable in create_imagenet.sh to the path" \
       "where the ImageNet validation data is stored."
  exit 1
fi

echo "RGB Creating train lmdb..."

GLOG_logtostderr=1 $TOOLS/convert_imageset \
    --resize_height=$RESIZE_HEIGHT \
    --resize_width=$RESIZE_WIDTH \
    --shuffle \
    $TRAIN_DATA_ROOT_RGB \
    $DATA/train_rgb.txt \
    $EXAMPLE/rgb_net_train_lmdb

echo "RGB Creating val lmdb..."

GLOG_logtostderr=1 $TOOLS/convert_imageset \
    --resize_height=$RESIZE_HEIGHT \
    --resize_width=$RESIZE_WIDTH \
    --shuffle \
    $VAL_DATA_ROOT_RGB \
    $DATA/val_rgb.txt \
    $EXAMPLE/rgb_net_val_lmdb

echo "Done."

########################################################



echo "D Creating train lmdb..."

GLOG_logtostderr=1 $TOOLS/convert_imageset \
    --resize_height=$RESIZE_HEIGHT \
    --resize_width=$RESIZE_WIDTH \
    --shuffle \
    $TRAIN_DATA_ROOT_D \
    $DATA/train_d.txt \
    $EXAMPLE/d_net_train_lmdb

echo "D Creating val lmdb..."

GLOG_logtostderr=1 $TOOLS/convert_imageset \
    --resize_height=$RESIZE_HEIGHT \
    --resize_width=$RESIZE_WIDTH \
    --shuffle \
    $VAL_DATA_ROOT_D \
    $DATA/val_d.txt \
    $EXAMPLE/d_net_val_lmdb

echo "Done."
