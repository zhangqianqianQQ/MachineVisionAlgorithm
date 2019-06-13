function [f] = HashingHist(PCANet,ImgIdx,OutImg)

NumImg = max(ImgIdx);
map_weights = 2.^((PCANet.NumFilters(end)-1):-1:0); % weights for binary to decimal conversion

for Idx = 1:NumImg
  
    Idx_span = find(ImgIdx == Idx);
    NumOs = length(Idx_span)/PCANet.NumFilters(end); % the number of "O"s
    Bhist = cell(NumOs,1);
    for i = 1:NumOs 
        T = 0;
        for j = 1:PCANet.NumFilters(end)
            T = T + map_weights(j)*Heaviside(OutImg{Idx_span(PCANet.NumFilters(end)*(i-1)+j)}); 
            % weighted combination; hashing codes to decimal number conversion
            
            OutImg{Idx_span(PCANet.NumFilters(end)*(i-1)+j)} = [];
        end
        Bhist{i} = T;
    end           
    f = Bhist;
end

%-------------------------------
function X = Heaviside(X) % binary quantization
X = sign(X);
X(X<=0) = 0;


