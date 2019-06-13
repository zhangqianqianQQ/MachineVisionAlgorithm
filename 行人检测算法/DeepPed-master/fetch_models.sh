#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

FILE=DeepPed.tar.gz
CHECKSUM=deddc4c230904f726f9ccc865bc747b1

if [ -f $FILE ]; then
  echo "File already exists. Checking md5..."
  os=`uname -s`
  if [ "$os" = "Linux" ]; then
    checksum=`md5sum $FILE | awk '{ print $1 }'`
  elif [ "$os" = "Darwin" ]; then
    checksum=`cat $FILE | md5`
  fi
  if [ "$checksum" = "$CHECKSUM" ]; then
    echo "Model checksum is correct. No need to download."
    exit 0
  else
    echo "Model checksum is incorrect. Need to download again."
  fi
fi

echo "Downloading precomputed DeepPed model (500 MB)..."

wget ftp://ftp.elet.polimi.it/users/Luca.Bondi/deepped/$FILE

echo "Unzipping..."

tar zxvf $FILE -C ../.

echo "Done. Please run this command again to verify that checksum = $CHECKSUM."
