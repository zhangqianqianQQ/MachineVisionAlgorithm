classdef RoiPoolingFreeform < dagnn.Layer
    % This layer has to be used AFTER the ROIPoolingFreeform.
    % It applies a mask to the roi-pooled activations, taking either fg, bg
    % or both of the image.
    %
    % inputs are: rois, masks, blobMasks
    % outputs are: rois
    %
    % Copyright by Holger Caesar, 2015
    
    properties
        combineFgBox = false;
    end
    
    properties (Transient)
        mask
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            assert(numel(inputs) == 3);
            [outputs{1}, obj.mask] = roiPooling_freeform_forward(inputs{1}, inputs{2}, inputs{3}, obj.combineFgBox);
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSL>
            assert(numel(derOutputs) == 1);
            derInputs{1} = roiPooling_freeform_backward(derOutputs{1}, obj.combineFgBox);
            derInputs{2} = [];
            derInputs{3} = [];
            derParams = {} ;
        end
        
        function obj = RoiPoolingFreeform(varargin)
            obj.load(varargin) ;
        end
    end
end