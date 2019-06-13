function [ out ] = Distance1D( hist1, hist2 )
%hist1 and hist2 are sets of three historgrams.  One for each color (R,G,B)

dR = EMD1D(hist1(:,1),hist2(:,1));
dG = EMD1D(hist1(:,2),hist2(:,2));
dB = EMD1D(hist1(:,3),hist2(:,3));

out = dR + dG + dB;

end