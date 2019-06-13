function net = initModel(param)
caffe.reset_all();
if exist(param.modelFile, 'file') == 0
  fprintf('%s does not exist. Start downloading ...\n', param.modelFile);
  downloadModel(param.modelName);
end
if ~exist(param.protoFile,'file')
  error('%s does not exist.', param.protoFile);
end

if param.useGPU
  fprintf('Using GPU Mode\n');
  caffe.set_mode_gpu();
  caffe.set_device(param.GPUID);
else
  fprintf('Using CPU Mode\n');
  caffe.set_mode_cpu;
end

net = caffe.Net(param.protoFile, param.modelFile, 'test');
