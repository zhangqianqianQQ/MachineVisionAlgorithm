testimgPath1 = [dir('I:\data\test\*.png');dir('I:\data\test\*.jpg')];
for num = 1:length(testimgPath1)
    file_name = testimgPath1(num).name;
    full_file_name = fullfile('I:\data\test',file_name);
    full_file_name1 = fullfile('I:\data\test\new',file_name);
    test_im = imread(full_file_name);
    test_out = padarray(test_im,[200,200],'both');
    imwrite(test_out,[full_file_name1 '.png'])
    
end;