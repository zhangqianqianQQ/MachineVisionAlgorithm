function [ out ] = Conway( scores )
%  Conway - Use simple form of Conway's game of life on score bitmap
%--------------------------------------------------------------------------
%   Params: scores - the score bitmap
%
%   Returns: out - the score bitmap after a simple Conway iteration
%
%--------------------------------------------------------------------------
out = scores;
for i = 2:length(scores(:,1))-1
    for j = 2:length(scores(1,:))-1
        if (scores(i,j)==1)
            if (sum(sum(scores(i-1:i+1,j-1:j+1)))<4)
                out(i,j)=0;
            end
        end
        if (scores(i,j)==0)
            if (sum(sum(scores(i-1:i+1,j-1:j+1)))>6)
                out(i,j)=1;
            end
        end
    end
end

end

