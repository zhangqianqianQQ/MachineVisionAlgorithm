function [ out ] = EMD1D( u, v )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
N = length(u);
cumDif = zeros(N+1,1);

for i = 1:N
    cumDif(i+1) = cumDif(i) + u(i) - v(i);
end

cumDif = abs(cumDif);
out = sum(cumDif);

end