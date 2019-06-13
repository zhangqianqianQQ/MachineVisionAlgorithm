%%
function [ chopped ] = chopp( bim ,sz1,sz2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   chop image break connected component
[h, w] = size(bim);
bout = bim;
for i = 1 : sz2 : w
    bout(:, i) = zeros(h, 1);
end

for j = 1 : sz1 : h
    bout (j, :) = zeros(1, w);
end
chopped = bout;

end

