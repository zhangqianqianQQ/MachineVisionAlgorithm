classdef GeneralSigmoid < dagnn.ElementWise
    % GeneralSigmoid
    %
    % Implements a general sigmoid layer (i.e. sigmoid of a 1d linear function):
    % S(x) = 1 / (1 + exp(- (ax + b) ))
    %
    % Note: This class is currently not used anywhere.
    %
    % For the derivatives check:
    % http://www.wolframalpha.com/input/?i=d%2Fdx+sigmoid%28ax%2Bb%29
    % http://www.wolframalpha.com/input/?i=d%2Fda+sigmoid%28ax%2Bb%29
    % http://www.wolframalpha.com/input/?i=d%2Fdb+sigmoid%28ax%2Bb%29
    %
    % Copyright by Holger Caesar, 2016
    
    properties
        numClasses = 0;
    end
    
    methods
        function obj = GeneralSigmoid(varargin)
            obj.load(varargin);
        end
        
        function outputs = forward(obj, inputs, params)
            % Get inputs
            assert(numel(inputs) == 1);
            assert(numel(params) == 2);
            x = inputs{1};
            a = params{1};
            b = params{2};
            assert(size(x, 3) == size(a, 1) && ...
                   size(x, 3) == size(b, 1));
            
            % Reshape parameters
            a = reshape(a, 1, 1, [], 1);
            b = reshape(b, 1, 1, [], 1);
            
            y = obj.sigmoid(x, a, b);
            outputs{1} = y;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
            
            % Get inputs
            assert(numel(derOutputs) == 1);
            x = inputs{1};
            a = params{1};
            b = params{2};
            dzdy = derOutputs{1};
            assert(all(size(x) == size(dzdy)));
            
            % Reshape parameters
            a = reshape(a, 1, 1, [], 1);
            b = reshape(b, 1, 1, [], 1);
            
            % Compute outputs and gradients
            % Note: this can be further optimized by summing first and then
            % multiplying.
            y = obj.sigmoid(x, a, b);
            dzdb = dzdy .* (y .* (1 - y));  % dzdb = dzdy * dydb
            dzda = bsxfun(@times, dzdb, x); % dzda = dzdy * dyda
            dzdx = bsxfun(@times, dzdb, a); % dzdx = dzdy * dydx
            
            % Sum over regions (not for dzdx!)
            dzda = reshape((sum(dzda, 4)), [], 1);
            dzdb = reshape((sum(dzdb, 4)), [], 1);
            
            % Store outputs
            assert(all(size(x) == size(dzdx)));
            derInputs{1} = dzdx;
            derParams{1} = dzda;
            derParams{2} = dzdb;
        end
        
        function params = initParams(obj)
            % Note that compared to the Caesar BMVC 2015 paper, we use the proper
            % sigmoid function with the "-" sign. Hence the "a" parameter
            % should be positive!
            params{1} = repmat(single(1), [obj.numClasses, 1]);
            params{2} = repmat(single(0), [obj.numClasses, 1]); %zeros([obj.numClasses, 1], 'single');
        end
    end
    
    methods (Access = protected)
        function[y] = sigmoid(obj, x, a, b) %#ok<INUSL>

            linear = bsxfun(@plus, bsxfun(@times, x, a), b);
            y = 1 ./ (1 + exp(- (linear)));
        end
    end
end