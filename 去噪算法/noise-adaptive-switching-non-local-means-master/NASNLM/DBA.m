%% Implementation of Decision-Based Algorithm for Removal of High-Density
%% Impulse Noises
%% Base Paper : "A New Fast and Efficient Decision-Based Algorithm for 
%  Removal of High-Density Impulse Noises", IEEE Sigmal Pricessing Letter, 
%  Vol. 14,No. 3, Mar 2007.
%% Function Y = DBAIN(x)
%% input    x = Given an Image
%%          
%%  Example: Y = DBAIN(x);
%%      Posted date   : 23 - 10 - 2008
%%      Modified date : 
%%                  
%% Developed By : K.Kannan (kannan.keizer@gmail.com) 
%%                & Jeny Rajan (jenyrajan@gmail.com)
%%                  Medical Imaging Research Group (MIRG), NeST,
%%                  Trivandrum.
%% 
%% Decision-Based Algorithm for Removal of High-Density Impulse Noises
function Y = DBA(x)

Y = double(x);
[R C] = size(x);
%% Implementation
for i = 2:R-1
    for j = 2:C-1
        clear tmp;
        tmp = Y(i-1:i+1,j-1:j+1);
        flg = 0;
        S = sort(tmp(:));
        if Y(i,j) == 0 || Y(i,j) == 255
            flg = 1;
        end
        if flg == 0 % if the Pixel is uncorrupted.
            if S(1) < Y(i,j) && Y(i,j) < S(5) && 0 < S(1) && S(9) < 255 % The 
                % P(X,Y) is an uncorrupted pixel if  Pmin < P(X,Y) < Pmax,
                % Pmin > 0 and Pmax < 255; the pixel being processed is 
                % left unchanged. Otherwise, P(X,Y) is a corrupted pixel.
                Y(i,j) = Y(i,j);
            end
        else % if the Pixel is corrupted.
            if S(1) < S(5) && S(5) < S(9) && 0 < S(5) && S(5) < 255 % If P(X,Y)
                % is a corrupted pixel, it is replaced by its median value 
                % if Pmin < Pmed < Pmax and 0 < Pmed < 255.
                Y(i,j) = S(5);
            end
            if S(1) >= S(5) || S(5) >= S(9) || S(5) == 255 && S(5) == 0
                % If Pmin < Pmed < Pmax  is not satisfied or 255 < Pmed = 0,
                % then is a noisy pixel. In this case, the P(X,Y) is replaced
                % by the value of neighborhood pixel value.
                Y(i,j) = Y(i,j-1);
            end
        end
    end
end
%% Border Correction 
Y(1,:) = Y(2,:);
Y(R,:) = Y(R-1,:);
Y(:,1) = Y(:,2);
Y(:,C) = Y(:,C-1);
