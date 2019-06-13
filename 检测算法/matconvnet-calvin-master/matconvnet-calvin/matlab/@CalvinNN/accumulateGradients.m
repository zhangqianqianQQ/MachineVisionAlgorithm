function state = accumulateGradients(obj, state, net, batchSize)
% state = accumulateGradients(obj, state, net, batchSize)
%
% Perform a Stochastic Gradient Descent update step of the network weights
% using momentum and weight decay.
%
% Copyright by Matconvnet (cnn_train_dag.m)
% Modified by Holger Caesar, 2016

for p = 1 : numel(net.params)
    switch net.params(p).trainMethod
        case 'average' % mainly for batch normalization
            thisLR = net.params(p).learningRate;
            net.params(p).value = ...
                (1 - thisLR) * net.params(p).value + ...
                (thisLR / batchSize / net.params(p).fanout) * net.params(p).der;
            assert(gather(~any(isnan(net.params(p).value(:)))));
        case 'gradient'
            thisDecay = obj.nnOpts.weightDecay * net.params(p).weightDecay;
            thisLR = state.learningRate * net.params(p).learningRate;
            state.momentum{p} = obj.nnOpts.momentum * state.momentum{p} ...
                - thisDecay * net.params(p).value ...
                - (1 / batchSize) * net.params(p).der;
            net.params(p).value = net.params(p).value + thisLR * state.momentum{p};
            
        case 'otherwise'
            error('Unknown training method ''%s'' for parameter ''%s''.', ...
                net.params(p).trainMethod, ...
                net.params(p).name);
    end
end