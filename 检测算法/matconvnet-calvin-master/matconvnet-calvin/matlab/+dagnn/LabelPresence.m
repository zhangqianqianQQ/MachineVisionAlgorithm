classdef LabelPresence < dagnn.Layer
    % Convert pixel label scores to presence/absence scores for each class per batch.
    % (to be able to compute an image-level loss there)
    %
    % inputs are: scoresSP, labelImage
    % outputs are: scoresImage
    %
    % Copyright by Holger Caesar, 2015
    
    properties (Transient)
        mask
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            
            % Get inputs
            assert(numel(inputs) == 2);
            scoresSP = inputs{1};
            labelImage = inputs{2};
            
            % Move to CPU
            gpuMode = isa(scoresSP, 'gpuArray');
            if gpuMode
                scoresSP = gather(scoresSP);
            end
            
            % Init
            labelList = unique(labelImage);
            labelListCount = numel(labelList);
            labelCount = size(scoresSP, 3);
            scoresImage = nan(1, 1, labelCount, labelListCount, 'single'); % score of the label, and all other labels
            obj.mask = nan(labelCount, labelListCount); % contains the label of each superpixel
            
            % For each label, get the scores of the highest scoring pixel
            for labelListIdx = 1 : labelListCount,
                labelIdx = labelList(labelListIdx);
                [~, spIdx] = max(scoresSP(:, :, labelIdx, :), [], 4);
                scoresImage(:, :, :, labelListIdx) = scoresSP(:, :, :, spIdx);
                obj.mask(:, labelListIdx) = spIdx;
            end
            
            % Convert outputs back to GPU if necessary
            if gpuMode
                scoresImage = gpuArray(scoresImage);
            end
            
            % Store outputs
            outputs = cell(1, 1);
            outputs{1} = scoresImage;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSL>
            %
            % This uses the mask saved in the forward pass.
            
            % Get inputs
            assert(numel(derOutputs) == 1);
            spCount = size(inputs{1}, 4);
            dzdy = derOutputs{1};
            
            % Move inputs from GPU if necessary
            gpuMode = isa(dzdy, 'gpuArray');
            if gpuMode
                dzdy = gather(dzdy);
            end
            
            % Map Image gradients to RP+GT gradients
            dzdx = labelPresence_backward(spCount, obj.mask, dzdy);
            
            % Move outputs to GPU if necessary
            if gpuMode
                dzdx = gpuArray(dzdx);
            end
            
            % Store gradients
            derInputs{1} = dzdx;
            derInputs{2} = [];
            derParams = {};
        end
        
        function obj = LabelPresence(varargin)
            obj.load(varargin);
        end
    end
end