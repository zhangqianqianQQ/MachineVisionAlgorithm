import theano.tensor as T
from lasagne import layers
from nolearn.lasagne import NeuralNet,BatchIterator
import numpy as np
import theano
import cPickle
import lasagne
from lasagne.updates import nesterov_momentum,adagrad
from nolearn.lasagne import TrainSplit
from lasagne.layers.dnn import Conv2DDNNLayer as ConvLayer
from lasagne.layers import MaxPool2DLayer as PoolLayer
from lasagne.nonlinearities import softmax
from nolearn.lasagne import TrainSplit 
from prepData import load_matfile
import sys
import matplotlib.pyplot as plt
from numpy.random import shuffle
sys.setrecursionlimit(1500)
cr=30

class AdjustVariable(object):
    def __init__(self, name, start=0.03, stop=0.001):
        self.name = name
        self.start, self.stop = start, stop
        self.ls = None

    def __call__(self, nn, train_history):
        if self.ls is None:
            self.ls = np.linspace(self.start, self.stop, nn.max_epochs)

        epoch = train_history[-1]['epoch']
        new_value = np.float32(self.ls[epoch - 1])
        getattr(nn, self.name).set_value(new_value)

class FlipBatchIterator(BatchIterator):
    def transform(self, Xb, yb):
        Xb, yb = super(FlipBatchIterator, self).transform(Xb, yb)

        # Flip half of the images in this batch at random:
        #bs = Xb.shape[0]
        #indices = np.random.choice(bs, bs / 2, replace=False)
        bs = Xb.shape[0]
        num_ch= np.int(2*bs / 3)
        indices = np.random.choice(bs,num_ch, replace=False)
        
        ind1=   indices[0:num_ch/2]
        ind2=   indices[num_ch/2:]        
                
        Xb[ind1] = Xb[ind1, :, :, ::-1]
        
        Xb[ind2] = Xb[ind2, :, ::-1,:]
        
        return Xb, yb
        
class EarlyStopping(object):
    def __init__(self, patience=100):
        self.patience = patience
        self.best_valid = np.inf
        self.best_valid_epoch = 0
        self.best_weights = None
        
#        meanDataFile='32in_32out-retrainsig25_denoise_meanData.dat'
#        fp=open(meanDataFile,'rb')
#        self.meanX,mean_y=cPickle.load(fp);
#        fp.close()
#        self.img_clean=convert_to_rgb(cv2.imread('./images/Lena512rgb.png'))
        

    def __call__(self, nn, train_history):
        current_valid = train_history[-1]['valid_loss']
        current_epoch = train_history[-1]['epoch']
        if current_valid < self.best_valid:
            self.best_valid = current_valid
            self.best_valid_epoch = current_epoch
            self.best_weights = nn.get_all_params_values()
        elif self.best_valid_epoch + self.patience < current_epoch:
            print("Early stopping.")
            print("Best valid loss was {:.6f} at epoch {}.".format(
                self.best_valid, self.best_valid_epoch))
            nn.load_params_from(self.best_weights)
            raise StopIteration()
            
        #f = open("allfonts_inter_impainter_cnn.dump", "wb")
        #cPickle.dump(nn, f, -1)
        #f.close()
        
def network():
    
    net = NeuralNet(
    layers=[
        ('input', layers.InputLayer),
        ('conv1', ConvLayer),
        ('conv2', ConvLayer),
        ('conv3', ConvLayer),
        ('conv4', ConvLayer),
        ('hidden1', layers.DenseLayer),
        ('hidden2', layers.DenseLayer),
        ('output', layers.DenseLayer),
        ],
        
    input_shape=(None, cr, 5, 5),
    conv1_num_filters=3*cr, conv1_filter_size=(3, 3), conv1_pad=1,
    conv2_num_filters=6*cr, conv2_filter_size=(3, 3), conv2_pad=1,
    conv3_num_filters=6*cr, conv3_filter_size=(3, 3),
    conv4_num_filters=9*cr, conv4_filter_size=(3, 3),
    hidden1_num_units=6*cr,
    hidden2_num_units=3*cr,
    output_num_units=16, output_nonlinearity=softmax,
    update=adagrad,
    update_learning_rate=theano.shared(np.float32(0.005)),
    #update_momentum=theano.shared(np.float32(0.9)),

    regression=False,
    on_epoch_finished=[
        AdjustVariable('update_learning_rate', start=0.005, stop=0.005),
        #AdjustVariable('update_momentum', start=0.9, stop=0.999),
        EarlyStopping(patience=40),
        ],
    train_split=TrainSplit(eval_size=0.1), 
    batch_iterator_train=FlipBatchIterator(batch_size=512),
    max_epochs=500,
    verbose=2,
    )
    return net

def predict_im(X,gt,net,mean,std):
    print 'Predicting image'
    h,w,ch=X.shape
    y_pred=np.zeros((h,w),dtype='uint8')
    conv_filter_size=5;
    b_size=(conv_filter_size-1)/2
    reflect = cv2.copyMakeBorder(X,b_size,b_size,b_size,b_size,cv2.BORDER_REFLECT)
    
    for y in range(h):
        print 'Y=',y
        for x in range(w):
            patch_i=reflect[y:y+conv_filter_size,y:y+conv_filter_size,:]
            patch_i=patch_i.transpose(2,0,1)
            patch_i=(patch_i[None,:]-mean)/std
            
            print patch_i.shape
            
            y_pred[y,x]=net.predict(patch_i)
    
    return y_pred            
            
    
def train_network(X,y,prefix,mean,std):
    net=network()
    net.fit(X, y)
    # Save models.
    f = open(prefix+".dump", "wb")
    cPickle.dump((net,mean,std), f, -1)
    f.close()
    
    return net
    
def plot_predict_gt(y_pred,y_true,filename='./results/pines'):
    f, axarr = plt.subplots(2)
    
    print y_true.shape
    axarr[0].imshow(y_pred.astype('uint8'))
    axarr[0].set_title('Predicted label')
    
    axarr[1].imshow(y_true.astype('uint8'))
    axarr[1].set_title('True label')
    
    plt.imsave(filename+'_gt.png',y_true)
    plt.imsave(filename+'_pred.png',y_pred)
    
def train_pines(is_train=True):
    X,y,gt=load_matfile(filename='./data/Indian_pines_pca.mat')
    num_pix=len(X)
    
    #shuffle idx
    idx=np.asarray(range(num_pix),dtype='uint')
    shuffle(idx)
    
    train_size=np.round(0.8*num_pix)

    X_train=X[idx[:train_size]].astype('float32')
    y_train=y[idx[:train_size]]
    
    X_test=X[idx[train_size:]].astype('float32')
    y_test=y[idx[train_size:]]
    
    if is_train:
        std=np.std(X_train)
        mean=np.mean(X_train)
        X_train=(X_train-mean)/std    
        prefix='./model/classify_pines'
        net=train_network(X_train,y_train,prefix,mean,std)
    else:
        f = open('./model/classify_pines.dump', 'rb')
        net,mean,std=cPickle.load(f)
        f.close()
        
    X_test=(X_test-mean)/std    
    y_pred=net.predict(X_test)
    acc=np.sum(y_pred==y_test)*1.0/len(y_test)
    print 'Test Accuracy= ',acc*100,' %'
    
    print gt.shape
    y_array=np.zeros(gt.shape,dtype='uint8')
    y_array[gt!=0]=net.predict((X-mean)/std)+1
    #y_array=predict_im(im,gt,net,mean,std)
    plot_predict_gt(y_array,gt,filename='./results/pines')
    
    return net,y_pred

def train_pavia(is_train=True):
    X,y,gt=load_matfile(filename='./data/Pavia_U_pca.mat')
    num_pix=len(X)
    
    #shuffle idx
    idx=np.asarray(range(num_pix),dtype='uint')
    shuffle(idx)
    
    train_size=np.round(0.8*num_pix)

    X_train=X[idx[:train_size]].astype('float32')
    y_train=y[idx[:train_size]]
    
    X_test=X[idx[train_size:]].astype('float32')
    y_test=y[idx[train_size:]]
    
    
    if is_train:
        std=np.std(X_train)
        mean=np.mean(X_train)
        X_train=(X_train-mean)/std    
        prefix='./model/classify_pavia_U'
        net=train_network(X_train,y_train,prefix,mean,std)
    else:
        f = open('./model/classify_pavia_U.dump', 'rb')
        net,mean,std=cPickle.load(f)
        f.close()
    
    
    X_test=(X_test-mean)/std    
    y_pred=net.predict(X_test)
    acc=np.sum(y_pred==y_test)*1.0/len(y_test)
    print 'Test Accuracy= ',acc*100,' %'
    
    
   
    y_array=np.zeros(gt.shape,dtype='uint8')
    y_array[gt!=0]=net.predict((X-mean)/std)+1
    plot_predict_gt(y_array,gt,filename='./results/pavia')
    
    return net,y_pred


if __name__=='__main__':
    cr=30
    net1,y_pred1=train_pines(False)
    cr=10
    net2,y_pred2=train_pavia(False)
    
#    net,y_pred_lab=train()    
#    X,y=load_matfile(filename='./data/indian_pines_data_pca_all.mat')
#    X_all=X.transpose(3,2,1,0)
#    y_all=np.squeeze(y)
#    
#    #read the labels where not 0    
#    idx=(y_all!=0)
#    y_pred=np.zeros(y_all.shape)
#    y_pred[idx]=y_pred_lab
#    
#    plot_predict_gt(y_pred+1,y_all)