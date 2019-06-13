classdef SegmentationAccuracyFlexible < dagnn.Loss
    % Copyright by Matconvnet
    % Modified by Holger Caesar, 2016
    % - Changed number of classes from 21 to obj.labelCount
    
    properties
        labelCount = [];
    end
    
    properties (Transient)
        pixelAccuracy = 0
        meanAccuracy = 0
        meanIntersectionUnion = 0
        confusion = 0
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            
            % Check settings
            assert(~isempty(obj.labelCount));
            
            [~, predictions] = max(inputs{1}, [], 3);
            predictions = gather(predictions);
            labels = gather(inputs{2});
            
            % compute statistics only on accumulated pixels
            ok = labels > 0;
            numPixels = sum(ok(:));
            obj.confusion = obj.confusion + accumarray([labels(ok), predictions(ok)], 1, [obj.labelCount, obj.labelCount]);
            
            % Compute accuracies
            [obj.pixelAccuracy, obj.meanAccuracy, obj.meanIntersectionUnion] = confMatToAccuracies(obj.confusion);
            
            obj.average = [obj.pixelAccuracy; obj.meanAccuracy; obj.meanIntersectionUnion];
            obj.numAveraged = obj.numAveraged + numPixels;
            outputs{1} = obj.average;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSD>
            derInputs{1} = [];
            derInputs{2} = [];
            derParams = {};
        end
        
        function reset(obj)
            obj.confusion = 0;
            obj.pixelAccuracy = 0;
            obj.meanAccuracy = 0;
            obj.meanIntersectionUnion = 0;
            obj.average = [0; 0; 0];
            obj.numAveraged = 0;
        end
        
        function str = toString(obj)
            str = sprintf('acc:%.2f, mAcc:%.2f, mIU:%.2f', ...
                obj.pixelAccuracy, obj.meanAccuracy, obj.meanIntersectionUnion);
        end
        
        function obj = SegmentationAccuracyFlexible(varargin)
            obj.load(varargin);
        end
    end
end