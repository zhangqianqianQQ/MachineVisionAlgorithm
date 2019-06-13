function [ D ] = hausDim( I )
% HAUSDIM Returns the Haussdorf fractal dimension of an object represented by
% a binary image.
%
%    Returns the Haussdorf fractal dimension D of an object represented by the
%    binary image I. Nonzero pixels belong to an object and 0 pixels 
%    constitute the background.
%
%    Algorithm
%    ---------
%    1 - Pad the image with background pixels so that its dimensions are a 
%        power of 2.
%    2 - Set the box size 'e' to the size of the image.
%    3 - Compute N(e), which corresponds to the number of boxes of size 'e' 
%        which contains at least one object pixel.
%    4 - If e > 1 then e = e / 2 and repeat step 3.
%    5 - Compute the points log(N(e)) x log(1/e) and use the least squares 
%        method to fit a line to the points.
%    6 - The returned Haussdorf fractal dimension D is the slope of the line.
%
%    Author
%    ------
%    Alceu Ferraz Costa 
%    email: alceufc [at] icmc [dot] usp [dot] br
%

    % Pad the image with background pixels so that its dimensions are a power 
    % of 2.
    maxDim = max(size(I));
    newDimSize = 2^ceil(log2(maxDim));
    rowPad = newDimSize - size(I, 1);
    colPad = newDimSize - size(I, 2);
    I = padarray(I, [rowPad, colPad], 'post');

    boxCounts = zeros(1, ceil(log2(maxDim)));
    resolutions = zeros(1, ceil(log2(maxDim)));
    
    iSize = size(I, 1);
    boxSize = iSize;
    boxesPerDim = 1;
    idx = 0;
    while boxSize >= 1
        boxCount = 0;
        
        minBox = (1: boxSize: (iSize - boxSize) + 1);
        maxBox = (boxSize: boxSize: iSize);
        
        for boxRow = 1:boxesPerDim
            for boxCol = 1:boxesPerDim
                objFound = false;
                for row = minBox(boxRow) : maxBox(boxRow)
                    for col = minBox(boxCol) : maxBox(boxCol)
                        if I(row, col)
                            boxCount = boxCount + 1;
                            objFound = true; % Break from nested loop.
                            break;
                        end;
                    end;
                    
                    if objFound
                        break; % Break from nested loop.
                    end;
                end;
            end;
        end;
        
        idx = idx + 1;
        boxCounts(idx) = boxCount;
        resolutions(idx) = 1 / boxSize;
        
        boxesPerDim = boxesPerDim * 2;
        boxSize = boxSize / 2;
    end;
    
    D = polyfit(log(resolutions), log(boxCounts), 1);
    D = D(1);
end

