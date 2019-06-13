classdef SegmentationLossSemiSupervised < dagnn.Loss
    % SegmentationLossSemiSupervised
    %
    % Similar to dagnn.SegmentationLoss, but also sets pixel weights.
    %
    % Inputs: prediction, labels, labelsImage, [classWeights],
    % isWeaklySupervised, [masksThingsCell]
    % Outputs: loss
    %
    % Note: 
    %    - classWeights can be empty, which means they are ignored.
    %    - labels or labelsImage can be empty.
    %
    % Copyright by Holger Caesar, 2016
    
    properties
        layerFS
        layerWS
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            assert(numel(inputs) == 6);
            scoresMap = inputs{1};
            labels = inputs{2};
            labelsImage = inputs{3};
            classWeights = inputs{4};
            isWeaklySupervised = inputs{5};
            masksThingsCell = inputs{6};
            assert(~isempty(isWeaklySupervised));
            
            if isWeaklySupervised
                outputs = obj.layerWS.forward({scoresMap, labelsImage, classWeights, masksThingsCell}, {});
            else
                outputs = obj.layerFS.forward({scoresMap, labels, classWeights}, {});
            end
            
            % Combine loss statistics
            imageCount = size(scoresMap, 4);
            n = obj.numAveraged;
            m = n + imageCount;
            obj.average = (n * obj.average + double(gather(outputs{1}))) / m;
            obj.numAveraged = m;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, ~, derOutputs)
            scoresMap = inputs{1};
            labels = inputs{2};
            labelsImage = inputs{3};
            classWeights = inputs{4};
            isWeaklySupervised = inputs{5};

            if isWeaklySupervised
                derInputs = obj.layerWS.backward({scoresMap, labelsImage, classWeights}, {}, derOutputs);
            else
                derInputs = obj.layerFS.backward({scoresMap, labels, classWeights}, {}, derOutputs);
            end
            derInputs{5} = [];
            derInputs{6} = [];
            derParams = {};
        end
        
        function obj = SegmentationLossSemiSupervised(varargin)
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