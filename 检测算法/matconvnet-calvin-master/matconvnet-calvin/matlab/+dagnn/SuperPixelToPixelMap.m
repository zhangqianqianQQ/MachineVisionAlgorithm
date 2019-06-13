classdef SuperPixelToPixelMap < dagnn.Layer
    % Convert superpixel scores to pixel scores.
    % (to be able to compute an pixel-level loss there)
    %
    % inputs are: scoresSP, blobsSP, oriImSize
    % outputs are: scoresImage
    %
    % Copyright by Holger Caesar, 2015
    
    properties (Transient)
        mask
    end
    
    methods
        function outputs = forward(obj, inputs, params) %#ok<INUSD>
            
            % Get inputs
            assert(numel(inputs) == 3);
            scoresSP = inputs{1};
            blobsSP = inputs{2};
            oriImSize = inputs{3};
            labelCount = size(scoresSP, 3);
            spCount = size(scoresSP, 4);
            
            % Move to CPU
            gpuMode = isa(scoresSP, 'gpuArray');
            if gpuMode
                scoresSP = gather(scoresSP);
            end
            
            % Init (if we don't have scores for a pixel/superpixel, because it is not
            % included in any region, we just set all scores of that pixel to
            % the lowest score overall)
            minScore = min(scoresSP(:));
            assert(~isnan(minScore));
            scoresMap = minScore * ones(oriImSize(1), oriImSize(2), labelCount, 1, 'like', scoresSP);
            obj.mask = cell(spCount, labelCount);
            
            for spIdx = 1 : spCount
                
                % Skips SPs that don't have scores
                if any(isnan(scoresSP(:, :, :, spIdx)))
                    continue;
                end
                
                % Get all pix. coords for the mask
                blob = blobsSP(spIdx);
                [blobSubY, blobSubX] = blobToImageSubs(blob);
                
                % Copy scores to all pixels in that superpixel
                for labelIdx = 1 : labelCount
                    curInds = blobSubY + oriImSize(1) * (blobSubX-1) + oriImSize(1) * oriImSize(2) * (labelIdx-1);
                    obj.mask{spIdx, labelIdx} = curInds;
                    
                    curScore = scoresSP(:, :, labelIdx, spIdx);
                    scoresMap(curInds) = curScore;
                end
            end
            
            % Convert outputs back to GPU if necessary
            if gpuMode
                scoresMap = gpuArray(scoresMap);
            end
            
            % Store outputs
            outputs = cell(1, 1);
            outputs{1} = scoresMap;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs) %#ok<INUSL>
            
            % Get inputs
            assert(numel(derOutputs) == 1);
            scoresSP = inputs{1};
            labelCount = size(scoresSP, 3);
            spCount = size(scoresSP, 4);
            dzdy = derOutputs{1};
            
            % Move to CPU
            gpuMode = isa(dzdy, 'gpuArray');
            if gpuMode
                dzdy = gather(dzdy);
            end
            
            % Init
            dzdx = zeros(size(scoresSP), 'like', scoresSP);
            
            % Map pixel gradients to superpixels
            for spIdx = 1 : spCount                
                % Sum gradients for all pixels in that superpixel
                for labelIdx = 1 : labelCount
                    curInds = obj.mask{spIdx, labelIdx};
                    if ~isempty(curInds)
                        curGradients = dzdy(curInds);
                        dzdx(1, 1, labelIdx, spIdx) = sum(curGradients);
                    end
                end
            end
            
            % Convert outputs back to GPU if necessary
            gpuMode = isa(scoresSP, 'gpuArray');
            if gpuMode
                dzdx = gpuArray(dzdx);
            end
            
            % Store gradients
            derInputs{1} = dzdx;
            derInputs{2} = [];
            derInputs{3} = [];
            derParams = {};
        end
        
        function obj = SuperPixelToPixelMap(varargin)
            obj.load(varargin);
        end
    end
end