 % Required for parsing the labels and numbers. 
 files = dir('Data/*.jpg');
 for file = files
     [row,col] = size(file);
     for i=1:row
         % fprintf("File name %s", file(i).name);
         file_real_name = file(i).name;
         file_name = "Data/"+ file_real_name;
         label_name = "Labels/label_" + file_real_name + ".mat";
         label_name_num = "Labels/label_number_" + file_real_name + ".mat";
         img = imread(file_name{1});
         [labels, numlabels] = getSPLabels(img,200,1,150);
         save(label_name{1},'labels');
         save(label_name_num{1},'numlabels');
         labels = 0;
     end
 end