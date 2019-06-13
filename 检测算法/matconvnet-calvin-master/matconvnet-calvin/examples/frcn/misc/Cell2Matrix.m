function [m, c] = Cell2Matrix(cell, dim)
% m = Cell2Matrix(cell)
%
% Function concatenates all elements of a cell.
%
% cell:         1D cell structure. Elements in a cell should be 1D or 2D
%               matrices
% dim:          Dimension over which features are concatenated.
%               Default: 1.
%
% m:            Concatenated elements of the cell.
% c:            Indices of row/col vectors denoting the cell index where
%               feature came from

if nargin == 1
    dim = 1;
end

% Concatenate all features in row direction.
if dim == 1
    % Calculate size for memory allocation
    mSize = 0;
    for i=1:length(cell)
        mSize = mSize + size(cell{i}, 1);
    end
    
    % Get number of columns for m
    nrC = 0;
    for i=1:length(cell)
        if size(cell{i}, 1) > 0
            nrC = size(cell{i}, 2);
            break;
        end
    end
    if nrC == 0  % All cells are empty
        m = [];
        c = [];
        return
    end

    % Concatenate everything.
    if isnumeric(class(cell{1}))
        m = zeros(mSize, nrC, class(cell{1}));
    else
        m = zeros(mSize, nrC);
    end
    c = zeros(mSize, 1);
    idx = 1;
    for i=1:length(cell)
        fSize = size(cell{i},1);
        if fSize ~= 0
            m(idx:idx+fSize-1, :) = cell{i};
            c(idx:idx+fSize-1, 1) = i;
        end
        idx = idx + fSize;
    end
end

% concatenate all features in col direction.
if dim == 2
    % Calculate size for memory allocation
    mSize = 0;
    for i=1:length(cell)
        mSize = mSize + size(cell{i}, 2);
    end

    % Concatenate everything.
    m = zeros(size(cell{1}, 1), mSize);
    c = zeros(1, mSize);
    idx = 1;
    for i=1:length(cell)
        fSize = size(cell{i},2);
        if fSize ~= 0
            m(:, idx:idx+fSize-1) = cell{i};
            c(1, idx:idx+fSize-1) = i;
        end
        idx = idx + fSize;
    end
end