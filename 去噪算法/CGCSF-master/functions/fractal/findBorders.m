function [ Im ] = findBorders( I )
% FINDBORDERS Returns an binary image with the regions' boundaries of the input 
% image I.
%
%    FINDBORDERS returns a binary image with the regions' boundaries of the 
%    input image I. The input image I must be a binary image. The returned image
%    Im takes the value 1 if the corresponding pixel in I has the value 1 and 
%    at least one neighboring pixel with value 0. Otherwise Im takes the value
%    0.
%
%    Author
%    ------
%    Alceu Ferraz Costa 
%    email: alceufc [at] icmc [dot] usp [dot] br

    Im = false(size(I));
    
    I = padarray(I, [1, 1], 1);
    [h w] = size(Im);
    
    bkgFound = false;
    for row = 1 : h
        for col = 1 : w
            if I(row + 1, col + 1)
                
                bkgFound = false;
                for i = 0:2
                    for j = 0:2
                        if ~I(row + i, col + j)
                            Im(row, col) = 1;
                            bkgFound = true;
                            break;
                        end;
                    end;
                    
                    if bkgFound
                        break;
                    end;
                end;
            end;
        end;
    end;
end

