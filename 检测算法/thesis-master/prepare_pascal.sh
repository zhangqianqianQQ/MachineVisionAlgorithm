DIR=~/datasets

# Download
wget -P $DIR http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2007/VOCtrainval_06-Nov-2007.tar
wget -P $DIR http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2007/VOCtest_06-Nov-2007.tar
wget -P $DIR http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2007/VOCdevkit_08-Jun-2007.tar

# Uncompressed
tar xvf $DIR/VOCtrainval_06-Nov-2007.tar -C $DIR
tar xvf $DIR/VOCtest_06-Nov-2007.tar -C $DIR
tar xvf $DIR/VOCdevkit_08-Jun-2007.tar -C $DIR

# Cleaning
rm -v $DIR/*.tar

