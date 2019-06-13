classdef ImageTile < handle
    % ImageTile This class holds a list of images.
    %
    % Upon request they can be placed into a single image in a given pattern.
    % Any non-color image will be converted to a color image.
    %
    % Copyright by Holger Caesar, 2014
    
    properties
        images
    end
    
    methods (Access = public)
        function[obj] = ImageTile()
            % [obj] = ImageTile()
            %
            % Initialize and empty image tile.
            
            obj.images = cell(0, 1);
        end
        
        function addImage(obj, image)
            % addImage(obj, image)
            %
            % Stores a copy of the image in the tile.
            
            obj.images{end+1, 1} = image;
        end
        
        function addTiling(obj, tiling)
            % addTiling(obj, tiling)
            %
            % Copies all images from that tiling to the current one.
            
            obj.images(end+1:end+numel(tiling.images), 1) = tiling.images;
        end
        
        function[totalX] = getTotalX(obj)
            totalX = numel(obj.images);
        end
        
        function[image] = getImage(obj, idx)
            image = obj.images{idx};
        end
        
        function[] = setImage(obj, idx, image)
            obj.images{idx} = image;
        end
        
        function[totalImage] = getTiling(obj, varargin)
            % [totalImage] = getTiling(obj, varargin)
            %
            % Compute an image that contains all images held by this tiling.
            
            % Get essential values
            numImages = numel(obj.images);
            sqNumImages = ceil(sqrt(numImages));
            
            % Parse input
            p = inputParser;
            addParameter(p, 'totalX', sqNumImages);
            addParameter(p, 'totalY', []);
            addParameter(p, 'delimiterPixels', 0);
            addParameter(p, 'minTotalSize', [0, 0]);
            addParameter(p, 'keepAspectRatio', true);
            addParameter(p, 'backgroundBlack', true);
            parse(p, varargin{:});
            
            totalX = p.Results.totalX;
            totalY = p.Results.totalY;
            delimiterPixels = p.Results.delimiterPixels;
            minTotalSize = p.Results.minTotalSize;
            keepAspectRatio = p.Results.keepAspectRatio;
            backgroundBlack = p.Results.backgroundBlack;
            
            % Early abort if there are no images
            if isempty(obj.images) || any(cellfun(@isempty, obj.images)),
                totalImage = [];
                return;
            end;
            
            % Compute tiling if only one size is known
            if isempty(totalY) && ~isempty(totalX),
                totalY = ceil(numImages / totalX);
            end;
            if isempty(totalX) && ~isempty(totalY),
                totalX = ceil(numImages / totalY);
            end;
            assert(totalY * totalX >= numImages);
            
            % Determine mean image size
            imSizes = cell2mat(cellfun(@(x) [size(x, 1), size(x, 2)], obj.images, 'UniformOutput', false));
            meanImSize = ceil(mean(imSizes, 1));
            
            % Determine total image size
            totalSize = meanImSize .* [totalY, totalX];
            
            % Correct mean image size if specified (and then meanImSize as
            % well)
            if totalSize(1) < minTotalSize(1),
                totalSize(1) = minTotalSize(1);
                meanImSize(1) = ceil(totalSize(1) / totalY);
            end;
            if totalSize(2) < minTotalSize(2),
                totalSize(2) = minTotalSize(2);
                meanImSize(2) = ceil(totalSize(2) / totalX);
            end;
            
            % Add delimiter pixels
            totalSize(1) = totalSize(1) + delimiterPixels * (totalY - 1);
            totalSize(2) = totalSize(2) + delimiterPixels * (totalX - 1);
            
            % Initialize image
            if backgroundBlack,
                totalImage = zeros(totalSize(1), totalSize(2), 3, 'uint8');
            else
                totalImage = ones(totalSize(1), totalSize(2), 3, 'uint8') * 255;
            end;
            
            for posIdx = 1 : numImages,
                % Get current image
                posImage = obj.images{posIdx};
                
                % Convert to color if necessary
                if size(posImage, 3) ~= 3,
                    posImage = repmat(posImage, [1, 1, 3]);
                end;
                
                % Convert to 8 bit if necessary
                posImage = im2uint8(posImage);
                
                if keepAspectRatio,
                    % Scale longer side to mean size and fill missing
                    % pixels with white color
                    
                    % Resize longer side to mean size
                    imageSize = [size(posImage, 1), size(posImage, 2)];
                    imageRatio = imageSize(1) / imageSize(2);
                    meanImRatio = meanImSize(1) / meanImSize(2);
                    if imageRatio > meanImRatio,
                        % Image is too high
                        targetSize = [meanImSize(1), nan];
                    elseif imageRatio < meanImRatio,
                        % Image is too wide
                        targetSize = [nan, meanImSize(2)];
                    else
                        % Ratio is correct
                        targetSize = meanImSize;
                    end;
                    posImage = imresize(posImage, targetSize);
                    
                    % Fill missing pixels with black color
                    fullPosImage = repmat(uint8(255), [meanImSize, 3]);
                    moveYStart = 1 + floor((meanImSize(1) - size(posImage, 1)) / 2);
                    moveYEnd = moveYStart + size(posImage, 1) - 1;
                    moveXStart = 1 + floor((meanImSize(2) - size(posImage, 2)) / 2);
                    moveXEnd = moveXStart + size(posImage, 2) - 1;
                    fullPosImage(moveYStart:moveYEnd, moveXStart:moveXEnd, :) = posImage;
                    posImage = fullPosImage;
                else
                    % Scale to mean size and destroy ratio
                    posImage = imresize(posImage, meanImSize);
                end;
                
                % Find out current position (go through x first!)
                posY = 1 + floor((posIdx - 1) / totalX);
                posX = posIdx - (posY-1) * totalX;
                
                % Insert current image into totalImage
                startY = 1 + meanImSize(1) * (posY-1) + delimiterPixels * (posY - 1);
                endY = meanImSize(1) * posY           + delimiterPixels * (posY - 1);
                
                startX = 1 + meanImSize(2) * (posX-1) + delimiterPixels * (posX - 1);
                endX = meanImSize(2) * posX           + delimiterPixels * (posX - 1);
                
                totalImage(startY:endY, startX:endX, :) = posImage;
            end;
        end
    end
end