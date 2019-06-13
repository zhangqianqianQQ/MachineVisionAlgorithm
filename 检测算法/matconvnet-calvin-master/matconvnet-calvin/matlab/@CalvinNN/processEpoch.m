function stats = processEpoch(obj, net, state)
% stats = processEpoch(obj, net, state)
%
% Processes one epoch (train, val or test).
%
% Copyright by Matconvnet
% Modified by Holger Caesar, 2016

% Initialize momentum on this worker
if strcmp(obj.imdb.datasetMode, 'train')
    state.momentum = num2cell(zeros(1, numel(net.params)));
end

% Move data to GPU and create memory map file for multiple GPUs
numGpus = numel(obj.nnOpts.gpus);
assert(numGpus <= 1);
if numGpus == 1
    net.move('gpu');
    if strcmp(obj.imdb.datasetMode, 'train')
        state.momentum = cellfun(@gpuArray, state.momentum, 'UniformOutput', false);
    end
end

% Get the indices of all batches
allBatchInds = state.allBatchInds;
assert(~isempty(allBatchInds));

% Initialize
epochNumElements = 0;
epochTimer = tic;
epochTime = 0;
fprintf('Starting %s epoch: %d\n', obj.imdb.datasetMode, state.epoch);

for t = 1 : obj.nnOpts.batchSize : numel(allBatchInds)
    batchNumElements = 0;
    
    for s = 1 : obj.nnOpts.numSubBatches
        % get this image batch and prefetch the next
        batchStart = t + s - 1;
        batchEnd = min(t + obj.nnOpts.batchSize - 1, numel(allBatchInds));
        batchInds = allBatchInds(batchStart : obj.nnOpts.numSubBatches : batchEnd);
        
        % Skip subbatches with no images
        if numel(batchInds) == 0,
            continue;
        end
        
        [inputs, numElements] = obj.imdb.getBatch(batchInds, net, obj.nnOpts);
        
        % Skip subbatches with no labels etc
        if numElements == 0
            continue;
        end
        
        if strcmp(obj.imdb.datasetMode, 'train')
            % Modification: Makes sure der's are reset even if s == 1 was empty
            net.accumulateParamDers = batchNumElements ~= 0;
            net.eval(inputs, obj.nnOpts.derOutputs);
        else
            net.eval(inputs);
        end
        
        % Extract results at test time (not val)
        if strcmp(obj.imdb.datasetMode, 'test')
            % Pre-allocate the struct-array for the results
            currResult = obj.nnOpts.testFn(obj.imdb, obj.nnOpts, net, inputs, batchInds);
            if t == 1 && s == 1
                results = repmat(currResult(1), numel(allBatchInds), 1);
            end
            results(batchInds) = currResult(1:numel(batchInds));
        end
        
        batchNumElements = batchNumElements + numElements;
        epochNumElements = epochNumElements + numElements;
    end
    
    % Extract learning stats
    if ~strcmp(obj.imdb.datasetMode, 'test')
        stats = obj.nnOpts.extractStatsFn(net, inputs);
    end
    
    % Accumulate gradients
    if strcmp(obj.imdb.datasetMode, 'train')
        state = obj.accumulateGradients(state, net, batchNumElements);
    end
    
    % Print learning statistics
    newEpochTime = toc(epochTimer);
    batchTime = newEpochTime - epochTime;
    epochTime = newEpochTime;
    
    stats.num = epochNumElements;
    stats.time = epochTime;
    
    curBatch = fix(t / obj.nnOpts.batchSize) + 1;
    totalBatches = ceil(numel(allBatchInds) / obj.nnOpts.batchSize);
    currentSpeed = batchNumElements / batchTime;
    averageSpeed = epochNumElements / epochTime;
    
    fprintf('%s: epoch %02d: %3d/%3d:', obj.imdb.datasetMode, state.epoch, ...
        curBatch, totalBatches);
    fprintf(' %.1f Hz (%.1f Hz)', averageSpeed, currentSpeed);
    
    for field = setdiff(fieldnames(stats)', {'num', 'time', 'results'})
        field = char(field); %#ok<FXSET>
        fprintf(' %s:', field);
        fprintf(' %.3f', stats.(field));
    end
    fprintf('\n');
end

% Give back results at test time
if strcmp(obj.imdb.datasetMode, 'test')
    stats.results = results; 
end

fprintf('Finished!\n');

net.reset();
net.move('cpu');