function [block wholeBlockRows wholeBlockCols] = subblocks(I, blockSizeR, blockSizeC) 

[rows columns] = size(I);
% blockSizeR = 128; % Rows in block.
% blockSizeC = 128; % Columns in block.
% Figure out the size of each block. 
wholeBlockRows = floor(rows / blockSizeR);
wholeBlockCols = floor(columns / blockSizeC);
blockNumber = 1;
i = 1;

for row = 1 : blockSizeR : rows
    for col = 1 : blockSizeC : columns
        row1 = row;
		row2 = row1 + blockSizeR - 1;
		row2 = min(rows, row2); 
        col1 = col;
		col2 = col1 + blockSizeC - 1;
		col2 = min(columns, col2);
        % Extract out the block into a single subimage.
        oneBlock = I(row1:row2, col1:col2);
        block{i} = mat2cell(oneBlock);
        blockNumber = blockNumber + 1;
        i = i + 1;
    end

end
