classdef SegmentationLossPixel < dagnn.Loss
    % SegmentationLossPixel
    %
    % Similar to dagnn.SegmentationLoss, but also sets pixel weights.
    %
    % Inputs: scoresMap, labels, classWeights
    % Outputs: loss
    %
    % Note: All weights can be empty, which means they are ignored.
    % Note: If you use this for weakly supervised, the loss output will be
    % wrong (divided by instances, not images)
    %
    % Copyright by Holger Caesar, 2016
    
    properties (Transient)
        instanceWeights
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>

            % Get inputs
            assert(numel(inputs) == 3);
            scoresMap = inputs{1};
            labels = inputs{2};
            classWeights = inputs{3};
            
            % Check inputs
            assert(~isempty(scoresMap));
            assert(~isempty(labels));
            
            % Compute invMass
            mass = sum(sum(labels > 0, 2), 1); % Removed the +1
            invMass = zeros(size(mass));
            nonEmpty = mass ~= 0;
            invMass(nonEmpty) = 1 ./ mass(nonEmpty);
            
            % Compute pixelWeights
            if isempty(classWeights)
                pixelWeights = [];
            else
                classWeightsPad = [0; classWeights(:)];
                
                %%% Pixel weighting
                pixelWeights = classWeightsPad(labels + 1);
                
                % Make sure mass of the image does not change
                curMasses = sum(sum(pixelWeights, 1), 2);
                divisor = curMasses ./ mass;
                valid = mass ~= 0 && curMasses ~= 0;
                if any(valid)
                    pixelWeights(:, :, :, valid) = bsxfun(@rdivide, pixelWeights(:, :, :, valid), divisor(valid));
                end
                
                % Checks
                pixelWeightsSum = sum(sum(pixelWeights, 1), 2);
                assert(all(abs(pixelWeightsSum - mass) < 1e-6) | pixelWeightsSum == 0);
            end;
            
            % Combine mass invMass and pixelWeights in instanceWeights
            obj.instanceWeights = invMass;
            if ~isempty(pixelWeights)
                obj.instanceWeights = bsxfun(@times, obj.instanceWeights, pixelWeights);
            end
                
            % Checks
            if ~isempty(obj.instanceWeights)
                assert(~any(isnan(obj.instanceWeights(:))))
            end
            
            % Compute loss
            loss = vl_nnloss(scoresMap, labels, [], ...
                'loss', obj.loss, ...
                'instanceWeights', obj.instanceWeights);
            
            assert(gather(~isnan(loss) && ~isinf(loss)));
            outputs{1} = loss;
            n = obj.numAveraged;
            m = n + size(scoresMap, 4);
            obj.average = (n * obj.average + double(gather(outputs{1}))) / m;
            obj.numAveraged = m;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSL>
            
            % Get inputs
            scoresMap = inputs{1};
            labels = inputs{2};
            
            derInputs{1} = vl_nnloss(scoresMap, labels, derOutputs{1}, ...
                'loss', obj.loss, ...
                'instanceWeights', obj.instanceWeights);
            derInputs{2} = [];
            derInputs{3} = [];
            derParams = {};
        end
        
        function obj = SegmentationLossPixel(varargin)
            obj.load(varargin);
        end
        
        function forwardAdvanced(obj, layer)
            % Modification: Overrides standard forward pass to avoid giving up when any of
            % the inputs is empty.
            
            in = layer.inputIndexes;
            out = layer.outputIndexes;
            par = layer.paramIndexes;
            net = obj.net;
            inputs = {net.vars(in).value};
            
            % clear inputs if not needed anymore
            for v = in
                net.numPendingVarRefs(v) = net.numPendingVarRefs(v) - 1;
                if net.numPendingVarRefs(v) == 0
                    if ~net.vars(v).precious && ~net.computingDerivative && net.conserveMemory
                        net.vars(v).value = [];
                    end
                end
            end
            
            % call the simplified interface
            outputs = obj.forward(inputs, {net.params(par).value});
            for oi = 1:numel(out)
                net.vars(out(oi)).value = outputs{oi};
            end
        end
    end
end