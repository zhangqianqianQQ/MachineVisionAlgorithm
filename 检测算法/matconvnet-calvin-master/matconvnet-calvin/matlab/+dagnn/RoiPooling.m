classdef RoiPooling < dagnn.Layer
    % Region of interest pooling layer.
    %
    % inputs are: convIm, oriImSize, boxes
    %   convIm:     height x width x channels x 1
    %   oriImSize:  1 x 3
    %   boxes:      1 x 1 x 4 x boxCount [x1, y1, x2, y2]
    %
    % outputs are: rois, masks
    %   rois:       poolSizeY x poolSizeX x channelCount x boxCount
    %   masks:      poolSizeY x poolSizeX x channelCount x boxCount
    %
    % Copyright by Holger Caesar, 2015
    
    properties
        poolSize = [1 1]
    end
    
    properties (Transient)
        mask
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            % Note: The mask is required here and (if existing) in the following
            % freeform layer.
            
            % Get inputs
            assert(numel(inputs) == 3);
            convIm    = inputs{1};
            oriImSize = inputs{2};
            boxes     = squeeze(inputs{3})';
            
            % Move inputs from GPU if necessary
            gpuMode = isa(convIm, 'gpuArray');
            if gpuMode,
                convIm = gather(convIm);
            end;
            
            % Perform ROI max-pooling (only works on CPU)
            [rois, obj.mask] = roiPooling_forward(convIm, oriImSize, boxes, obj.poolSize);
            
            % Move outputs to GPU if necessary
            if gpuMode,
                rois = gpuArray(rois);
            end;
            
            % Debug: Visualize ROIs
%             roiPooling_visualizeForward(boxes, oriImSize, convIm, rois, 1, 1);
            
            % Check size
            channelCount = size(convIm, 3);
            assert(all([size(rois, 1), size(rois, 2), size(rois, 3)] == [obj.poolSize, channelCount]));
            
            % Store outputs
            outputs{1} = rois;
            outputs{2} = obj.mask;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSL>

            % Get inputs
            assert(numel(derOutputs) == 1);
            convIm = inputs{1};
            boxes  = squeeze(inputs{3})';
            dzdy = derOutputs{1};
            boxCount = size(boxes, 1);
            convImSize = size(convIm);
            gpuMode = isa(dzdy, 'gpuArray');
            
            % Move inputs from GPU if necessary
            if gpuMode,
                dzdy = gather(dzdy);
            end;
            
            % Backpropagate derivatives (only works on CPU)
            dzdx = roiPooling_backward(boxCount, convImSize, obj.poolSize, obj.mask, dzdy);
            
            % Move outputs to GPU if necessary
            if gpuMode,
                dzdx = gpuArray(dzdx);
            end;
            
            % Debug: Visualize gradients
%             oriImSize = inputs{2};
%             roiPooling_visualizeBackward(oriImSize, boxes, obj.mask, dzdy, dzdx, 1, 1);
            
            % Store outputs
            derInputs{1} = dzdx;
            derInputs{2} = [];
            derInputs{3} = [];
            derParams = {};
        end
        
        function backwardAdvanced(obj, layer)
            % This layer needs to be modified as the output "label"
            % does not have a derivative and therefore backpropagation
            % would be skipped in the normal function.
            
            in = layer.inputIndexes;
            out = layer.outputIndexes;
            par = layer.paramIndexes;
            net = obj.net;
            
            % Modification: Only backprop gradients for activations, not
            % mask
            out = out(1);
            
            inputs = {net.vars(in).value};
            derOutputs = {net.vars(out).der};
            for i = 1:numel(derOutputs)
                if isempty(derOutputs{i}), return; end
            end
            
            if net.conserveMemory
                % clear output variables (value and derivative)
                % unless precious
                for i = out
                    if net.vars(i).precious, continue; end
                    net.vars(i).der = [];
                    net.vars(i).value = [];
                end
            end
            
            % compute derivatives of inputs and paramerters
            [derInputs, derParams] = obj.backward ...
                (inputs, {net.params(par).value}, derOutputs);
            
            % accumuate derivatives
            for i = 1:numel(in)
                v = in(i);
                if net.numPendingVarRefs(v) == 0 || isempty(net.vars(v).der)
                    net.vars(v).der = derInputs{i};
                elseif ~isempty(derInputs{i})
                    net.vars(v).der = net.vars(v).der + derInputs{i};
                end
                net.numPendingVarRefs(v) = net.numPendingVarRefs(v) + 1;
            end
            
            for i = 1:numel(par)
                p = par(i);
                if (net.numPendingParamRefs(p) == 0 && ~net.accumulateParamDers) ...
                        || isempty(net.params(p).der)
                    net.params(p).der = derParams{i};
                else
                    net.params(p).der = net.params(p).der + derParams{i};
                end
                net.numPendingParamRefs(p) = net.numPendingParamRefs(p) + 1;
            end
        end
        
        function obj = RoiPooling(varargin)
            obj.load(varargin);
        end
    end
end
