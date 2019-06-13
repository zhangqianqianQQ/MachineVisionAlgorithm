%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Code to run part-based RCNNs for fine-grained detection %
%%%% Usage: put pretrained deep model paths into cnn_models %%
%%%% Also define model definition file %%%%%%%%%%%%%%%%%%%%%%%
%%%% Change all the paths to your path %%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ning Zhang %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init;

results = run_classification(cnn_models, model_def);

