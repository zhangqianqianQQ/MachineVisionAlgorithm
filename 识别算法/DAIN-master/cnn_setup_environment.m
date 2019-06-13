function [ opts ] = cnn_setup_environment( varargin )

  run(fullfile(fileparts(mfilename('fullpath')), ...
         'matconvnet','matlab', 'vl_setupnn.m')) ;

  run(fullfile(fileparts(mfilename('fullpath')), ...
         'MexConv3D', 'setup_path.m')) ;   
  opts.dataPath = 'data';
  opts.modelPath ='models';
  opts.flowDir = 'data/Remat/diff_256';
  opts.imageDir  = 'data/Remat/jpegs_256';
  opts.numFetchThreads = 8 ;
  
  [opts, ~] = vl_argparse(opts, varargin);

  
end

