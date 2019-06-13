function Blk_cell = blocking_function( Mat, block_size, overlap )
%---------Blocking Function--------------------------------------%
% Purpose:
% This function takes a 2-D matrix 'Mat' as input
% and gives output blocks of size 'block_size' by 'block_size'
% with 'overlap' percentage
% 
% Input: Mat      -> input 2-D matrix (must be of size power of 2)
%        block_size -> Output block size (must be of power of 2 and
%                                          less than the Mat size)
%        overlap  -> percentage overlap between the
%                    adjacent blocks (default == 0% )
% 
% Output: Blk_cell -> A cell containing the output blocks
% 
% Author: Mushfiqul Alam
%         Laboratory of Computational Perception and Image Quality
%         Oklahoma State University, Stillwater, Oklahoma, USA.
%         E-mail:mdma@okstate.edu, mushfiqulalam@gmail.com
%-----------------------------------------------------------------%

if nargin == 1
    warning('Give the block size and the overlap'); %#ok<WNTAG>    
end

if nargin == 2
    overlap = 0;
end

% Size of matrix 
[ ht, wd ] = size( Mat );

% Calculating the Sliding length of the block
wd_slide_len = ceil( ( ( 100-overlap )/100 ) * block_size(2) );
ht_slide_len = ceil( ( ( 100-overlap )/100 ) * block_size(1) );

% Allocating space for output Blk_cell
jy = block_size(2)/2 : wd_slide_len : wd-block_size(2)/2;
ix = block_size(1)/2 : ht_slide_len : ht-block_size(1)/2;
Blk_cell  = cell( length(ix), length(jy) ); 

%% ------CALCULATING THE INDEX------------------------%

nx_idx = 1;
ny_idx = 1;

for jy = block_size(2)/2 : wd_slide_len : wd-block_size(2)/2
    for ix = block_size(1)/2 : ht_slide_len : ht-block_size(1)/2
               
        % choosing the current blocks
        current_blk = Mat( ( ix-block_size(1)/2+1 ) : ( ix+block_size(1)/2 ),...
                           ( jy-block_size(2)/2+1 ) : ( jy+block_size(2)/2 ) );
        
        Blk_cell{nx_idx, ny_idx} = current_blk;
        
        % Increasing the nx_idx by 1
        nx_idx = nx_idx + 1;
        
     end
    
    % Increasing the ny_idx by 1
    ny_idx = ny_idx + 1;
    
    % Setting nx_idx back to 1
    nx_idx = 1;
end

