function res = my_non_maxima(I, radii, threshold)

% non maxima supression, odd size mask
mask = 2*radii+1; 
max = ordfilt2(I,mask^2,true(mask));

% Maxima and Threshold
res = (I==max) & (I >threshold);   

return