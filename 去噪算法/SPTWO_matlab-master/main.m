clear
close all
PAR_DEFAULT_NPROC =  0;
PAR_DEFAULT_TAU    = 0.25;
PAR_DEFAULT_LAMBDA = 0.15;
PAR_DEFAULT_THETA  = 0.3;
PAR_DEFAULT_NSCALES =5;
PAR_DEFAULT_ZFACTOR =0.5;
PAR_DEFAULT_NWARPS = 5;
PAR_DEFAULT_EPSILON = 0.01;
useOracle = 'a';
lrdist = 0;
hBin = 0;
h02 = 0;
[width, height, nframes, nchannels, sequence] = ReadInputData('traffic.avi');
fparams.tau     = PAR_DEFAULT_TAU;
fparams.theta   = PAR_DEFAULT_THETA;
fparams.nscales = PAR_DEFAULT_NSCALES;
fparams.zfactor = PAR_DEFAULT_ZFACTOR;
fparams.warps  = PAR_DEFAULT_NWARPS;
fparams.epsilon = PAR_DEFAULT_EPSILON;
fparams.verbose = 0;
fparams.iflagMedian = 0;
N = 1 + log(hypot(width, height)/16.0) / log(1/fparams.zfactor);
%
   options.osigma = 	{"s:", 0, "5.0", [], "noise standard deviation"};
   
    options.oiFrame = {"i:", 0, "-1", [], "frame to denoise (-1: denoise all frames)"};
    
    
    %%Parameters
    options.oibloc = 	{"b:", 0, "12", [], "radius of search region"};
  
    options.oiwin = 	{"w:", 0, "2", [], "radius of patch"};
   
   options.oitemp = 	{"t:", 0, "7", [], "radius of temporal neighborhood"};
   
   options.oiknn = 	{"k:", 0, [], [], "minimum number of patches (recommended: 55 gray images, 95 color images)"};
 
   options.oflat = 	{"f:", 0, "0.85", [], "flat parameter"};
    
   options.olrdist = {"c:", 0, "1.0", [], "threshold for left-right coherence in occlusions mask"};
   
    options.ohbin = 	{"h:", 0, "0.5", [], "occlusion binarization threshold"};
   
    options.ofocc = 	{"o:", 0, "5.5", [], "occlusion factor"};
  
    options.ofpca1 = 	{"p:", 0, "1.8",[], "PCA factor 1st step"};
   
   options.ofpca2 = 	{"q:", 0, "1.45", [], "PCA factor 2nd step"};
   
   options.odist1 = 	{"d:", 0, "0.0", [], "3D blocks distances 1st step"};
    
    options.odist2 = 	{"e:", 0, "2.0",[], "3D blocks distances 2nd step"};
   
   options.olambda1 = 	{"l:", 0, "0.075", [], "optical flow lambda 1st step"};
   
   options.olambda2 = 	{"m:", 0, "0.15", [], "optical flow lambda 2nd step"};
  parameter.pinput = {"input", [], "input file"};
    
    parameter.pout = {"out", [], "output file"};
    
    %video Denoising Parameters not setted yet
    dparams.fSigma = str2double(options.osigma{3});
    iFrame = str2double(options.oiFrame{3});
    iscolor= nchannels;
    iBloc = 2*str2double(options.oibloc{3})+1;
    iWin  = 2*str2double(options.oiwin{3})+1;
    iTemp = 2*str2double(options.oitemp{3})+1;
    iKnn = 0;
    
   if(iscolor == 1)
       iKnn = 95;
   else
       iKnn = 55;
   end
    hBinTh =  str2double(options.ohbin{3});
    factorocc =  str2double(options.ofocc{3});
    factorflat = str2double(options.oflat{3});
    lrdistTh =  str2double(options.olrdist{3});
    factorPCA_1st = str2double(options.ofpca1{3});
    thdist_1st =  str2double(options.odist1{3});
    lambda_1st = str2double(options.olambda1{3});
    factorPCA_2nd = str2double(options.ofpca2{3});
    thdist_2nd = str2double(options.odist2{3});
    lambda_2nd = str2double(options.olambda2{3});
    % Global parameters denoising part %
    dparams.iFrames=nframes;
    dparams.iBloc = iBloc;
    dparams.iWin  = iWin;
    dparams.iTemp = iTemp;
    dparams.useFlatPar=factorflat;
    dparams.ifK = iKnn;
    % first iteration parameters %
    dparams.useOracle = 0;

    dparams.fRMult =  factorPCA_1st;
    dparams.fFixedThrDist = thdist_1st;
    fparams.lambda = lambda_1st;

    useOracle=dparams.useOracle;
    % denoising function %
    denoise_function(fparams, dparams, -1,nframes,useOracle,sequence);
 