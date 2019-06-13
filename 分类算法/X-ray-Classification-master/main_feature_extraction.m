% clc;
% clear;
% close all;

% TRAINING DATA -----------------------------------------------------------
%Train1 Training data
normalimgPath = dir('/home/jahnavi/Desktop/IIIT/3rd Year/Sem 6/Honors-2/10000 IRMA/Test/*.png'); 
for i = 1:length(normalimgPath) 
    file_name = normalimgPath(i).name; 
    full_file_name = fullfile('/home/jahnavi/Desktop/IIIT/3rd Year/Sem 6/Honors-2/10000 IRMA/Test',file_name); 
    I = imread(full_file_name);
    
    width = 512 - size(I,2) ;
    height = 512 - size(I,1) ;
    
    if rem(width,2) == 0
        pad_factor1 = width./2;
        pad_factor2 = width./2;
        I = padarray(I,[0,pad_factor1],'both');
    else
        pad_factor1 = floor(width./2);
        pad_factor2 = ceil(width./2);
        I = padarray(I,[0,pad_factor1],'pre');
        I = padarray(I,[0,pad_factor2],'post');
    end
    
    if rem(height,2) == 0
        pad_factor1 = height./2;
        pad_factor2 = height./2;
        I = padarray(I,[pad_factor1,0],'both');
    else
        pad_factor1 = floor(height./2);
        pad_factor2 = ceil(height./2);
        I = padarray(I,[pad_factor1,0],'pre');
        I = padarray(I,[pad_factor2,0],'post');
    end
   
    final_vector_test(i,:) = feature_vector(I);
end
final_vector_test = [final_vector_test, zeros(1,1000)'];
final_vector_test(:,113) = final_vector_test(:,113) + 0;

xlswrite('10000IRMA_Testing.xlsx',final_vector_test);
