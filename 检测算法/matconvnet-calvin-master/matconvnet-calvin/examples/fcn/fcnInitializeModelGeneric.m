function net = fcnInitializeModelGeneric(imdb, varargin)
%FCNINITIALIZEMODEL Initialize the FCN-32 model from VGG-VD-16
%
% Modifications:
%  - Works for any number of labels
%  - Various weight initialization options
%
% Copyright by Matconvnet
% Modified by Holger Caesar, 2016

opts.sourceModelUrl = 'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-16.mat';
opts.sourceModelPath = 'data/models/imagenet-vgg-verydeep-16.mat';
opts.adaptClassifier = true; % Changes number of classes to imdb.numClasses
opts.init = 'zeros';
opts.initLinCombPath = '';
opts = vl_argparse(opts, varargin);

% -------------------------------------------------------------------------
%                    Load & download the source model if needed (VGG VD 16)
% -------------------------------------------------------------------------
if ~exist(opts.sourceModelPath, 'file')
    fprintf('%s: downloading %s\n', opts.sourceModelUrl);
    mkdir(fileparts(opts.sourceModelPath));
    urlwrite(opts.sourceModelPath, opts.sourceModelUrl);
end
net = load(opts.sourceModelPath);

% -------------------------------------------------------------------------
%                                  Edit the model to create the FCN version
% -------------------------------------------------------------------------

% Add dropout to the fully-connected layers in the source model
drop1 = struct('name', 'dropout1', 'type', 'dropout', 'rate' , 0.5);
drop2 = struct('name', 'dropout2', 'type', 'dropout', 'rate' , 0.5);
net.layers = [net.layers(1:33) drop1 net.layers(34:35) drop2 net.layers(36:end)];

% Convert the model from SimpleNN to DagNN
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true);

% Add more padding to the input layer
net.layers( 5).block.pad = [0 1 0 1];
net.layers(10).block.pad = [0 1 0 1];
net.layers(17).block.pad = [0 1 0 1];
net.layers(24).block.pad = [0 1 0 1];
net.layers(31).block.pad = [0 1 0 1];
net.layers(32).block.pad = [3 3 3 3];

% Modify the bias learning rate for all layers
for i = 1:numel(net.layers)-1
    if (isa(net.layers(i).block, 'dagnn.Conv') && net.layers(i).block.hasBias)
        filt = net.getParamIndex(net.layers(i).params{1});
        bias = net.getParamIndex(net.layers(i).params{2});
        net.params(bias).learningRate = 2 * net.params(filt).learningRate;
    end
end

% Make sure fc8 bias is a row vector (different Matconvnet nets have
% different formats)
fc8Idx = net.getLayerIndex('fc8');
fc8fIdx = net.getParamIndex('fc8f');
fc8bIdx = net.getParamIndex('fc8b');
assert(~isnan(fc8Idx));
if size(net.params(fc8bIdx).value, 1) ~= 1
    net.params(fc8bIdx).value = net.params(fc8bIdx).value';
end

% Modify the last fully-connected layer to have numClasses output classes
if opts.adaptClassifier
    fc8fSize = size(net.params(fc8fIdx).value);
    fc8bSize = size(net.params(fc8bIdx).value);
    fc8fSize(end) = imdb.numClasses;
    fc8bSize(end) = imdb.numClasses;
    
    if strStartsWith(opts.init, 'lincomb')
        % Load linear combination weights
        assert(~isempty(opts.initLinCombPath));
        load(opts.initLinCombPath, 'linearCombination');
        
        % Weights
        oldWeights = net.params(fc8fIdx).value;
        newWeights = reshape(oldWeights, [size(oldWeights, 3), size(oldWeights, 4)]);
        newWeights = newWeights * linearCombination';
        newWeights = reshape(newWeights, [1, 1, size(newWeights)]);
        
        % Biases
        oldBias = net.params(fc8bIdx).value;
        net.params(fc8bIdx).value = zeros(fc8bSize, 'single');
        newBias = oldBias;
        newBias = newBias * linearCombination';
    elseif strStartsWith(opts.init, 'best')
        % Overwrite weights from known closest class in ILSVRC
        if strStartsWith(opts.init, 'best-auto')
            clsClassInds = imdb.dataset.findClosestIlsvrcClsClass(false);
        elseif strStartsWith(opts.init, 'best-manual')
            clsClassInds = imdb.dataset.findClosestIlsvrcClsClass(true);
        else
            error('Error: Unknown initialization!');
        end
        targetClassInds = 1:imdb.numClasses;
        sel = ~isnan(clsClassInds);
        clsClassInds = clsClassInds(sel);
        targetClassInds = targetClassInds(sel);
        
        % Weights
        oldWeights = net.params(fc8fIdx).value;
        newWeights = zeros(fc8fSize, 'single');
        newWeights(:, :, :, targetClassInds) = oldWeights(:, :, :, clsClassInds);
        
        % Biases
        oldBias = net.params(fc8bIdx).value;
        newBias = zeros(fc8bSize, 'single');
        newBias(:, targetClassInds) = oldBias(:, clsClassInds);
    elseif strStartsWith(opts.init, 'zeros')
        % Initialize the new filters to zero
        newWeights = zeros(fc8fSize, 'single');
        newBias = zeros(fc8bSize, 'single');
    else
        error('Error: Unknown initialization!');
    end
    
    % Set bias s.t. roughly half of the pixels will be bg
    % (median max score)
    if strEndsWith(opts.init, 'autobias')
        assert(imdb.dataset.annotation.labelOneIsBg);
        newWeights(:, :, :, 1) = 0;
        newBias(1) = imdb.dataset.getAutoBgBias();
    end
    
    % Update weights and bias
    net.params(fc8fIdx).value = newWeights;
    net.params(fc8bIdx).value = newBias;
    
    % Adapt block to new parameter size
    net.layers(fc8Idx).block.size = fc8fSize;
end

% Remove the last loss layer
net.removeLayer('prob');
net.setLayerOutputs('fc8', {'x38'});

% -------------------------------------------------------------------------
% Upsampling and prediction layer
% -------------------------------------------------------------------------

filters = single(bilinear_u(64, imdb.numClasses, imdb.numClasses));
net.addLayer('deconv32', ...
    dagnn.ConvTranspose(...
    'size', size(filters), ...
    'upsample', 32, ...
    'crop', [16 16 16 16], ...
    'numGroups', imdb.numClasses, ...
    'hasBias', false), ...
    'x38', 'prediction', 'deconvf');

f = net.getParamIndex('deconvf');
net.params(f).value = filters;
net.params(f).learningRate = 0;
net.params(f).weightDecay = 1;

% Make the output of the bilinear interpolator is not discared for
% visualization purposes
net.vars(net.getVarIndex('prediction')).precious = 1;

% -------------------------------------------------------------------------
% Losses and statistics
% -------------------------------------------------------------------------

% Add loss layer
net.addLayer('objective', ...
    SegmentationLoss('loss', 'softmaxlog'), ...
    {'prediction', 'label'}, 'objective');

% Add accuracy layer
net.addLayer('accuracy', ...
    SegmentationAccuracy(), ...
    {'prediction', 'label'}, 'accuracy');

if 0
    figure(100); clf; %#ok<UNRCH>
    n = numel(net.vars);
    for i=1:n
        vl_tightsubplot(n,i);
        showRF(net, 'input', net.vars(i).name);
        title(sprintf('%s', net.vars(i).name));
        drawnow;
    end
end
