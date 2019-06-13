
clc;
clear all;
close all;


%step 1: read specific folders -- specific target data
%step2: each image, resize it to 64x64 and train svm
%step3: perform classification


data_path='<input_data_path>'

train_data_path=fullfile(data_path,'Training');
test_data_path=fullfile(data_path,'Testing');

class_name={<class_names>};

training_features=[];
training_labels=[];

testing_features=[];
testing_labels=[];
jj=0;


%training
for index=1:size(class_name,2)

    %which class are you processing
    sprintf('process class -- %d',index)
    
    %process each class data
     class_data=fullfile(train_data_path,class_name{1,index});
     image_files_list=dir([class_data '/*.ppm']);
    
     
    
     training_labels= [training_labels;  index.*ones(size(image_files_list,1),1)];
     
     % process each image of a particular class
     for ii=1:length(image_files_list)
        jj=jj+1;
        %file_name=image_files_list(ii).name;
        image_path=fullfile(train_data_path,class_name,image_files_list(ii).name);
        image=imread(image_path{1,index}); 
        
               
        
        %-------------------------------------------------------------
        %step 2: resize, extract HOG and train SVM
        %-------------------------------------------------------------
        
        
        
        
        %[hog_features,viz]= extractHOGFeatures(resize_image,'CellSize',[5 5]);
        
        training_features(jj,:)= extractHOGFeatures(resize_image,'CellSize',[5 5]);
       
        
     end     
    
end
classifier=fitcecoc(training_features,training_labels);

%}
%error('completed training ....')


%-----------
% testing
%-----------

close all
out_path='<output_path>;
image_files_list=dir([test_video_frame '/*.jpg']);
   

for ii=1:size(image_files_list)

       %initialize label
        predictedLabels={};
        
        file_name=image_files_list(ii).name;
        sprintf('predicting for %s',image_files_list(ii).name)
        % force the ordering
        
        image_path=fullfile(test_video_frame,strcat(int2str(ii),'.jpg'));
        image=imread(image_path); 
        
              
        
        resize_image=imresize(image,[64 64]);
        resize_image=imbinarize(rgb2gray(resize_image));
        
         
        % get the bounding boxes
        bbox_list =function_compute_bbox(resize_image);
        
               
        if isempty(bbox_list)
            %error('do you want to save when nothing is detected???')
            disp('no bounding box detected ...');
            savePath=fullfile(out_path,file_name);
            imwrite(image, savePath );
        
        else
                %for each bounding box train, as a class
                for bbox_index=1:size(bbox_list,1)
                     %bb_image=imcrop()
                     %error('found....')

                     y_start_lim=bbox_list(bbox_index,2);
                    y_end_lim=bbox_list(bbox_index,4);
                    x_start_lim=bbox_list(bbox_index,1);
                    x_end_lim=bbox_list(bbox_index,3);

                     %bb_image=image(floor(bbox_list(bbox_index,2)):floor(bbox_list(bbox_index,4)+1), ...
                        %  floor(bbox_list(bbox_index,1)): floor(bbox_list(bbox_index,3))+1);

                      bb_image=image(floor(y_start_lim:y_start_lim+y_end_lim+1) ,floor(x_start_lim:x_start_lim+x_end_lim+1));
                      %imshow(bb_image)
                      %error('dddddd')
                      
                      %rescale the bounding box for HOG feature extraction
                      bb_image=imresize(bb_image,[64 64]);
                      
                      %compute hog feature and add to list

                    testing_features= extractHOGFeatures(bb_image,'CellSize',[5 5]);

                    label=class_name{1,predict(classifier, testing_features)};   
                    predictedLabels{bbox_index} =  label;
                
           end
                    
                
                    f=figure;
                    set(f,'Visible','off');
                    imshow(insertObjectAnnotation(image, 'rectangle',bbox_list,predictedLabels ,...
                                                                 'FontSize',22, ...
                                                                'TextBoxOpacity',0.8));
                                                               
                     %title('Show Detected Sign')
                       
            

                savePath=fullfile(out_path,file_name);
                saveas(f, savePath );
                 
        
        end
                   
     end    
    

%generate confusion matrix
dictedLabels = predict(classifier, testing_features);
confMat = confusionmat(testing_labels, predictedLabels);
helperDisplayConfusionMatrix(confMat)
