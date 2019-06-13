%just test whether svm toolbox in correctly installed
[heart_scale_label,heart_scale_inst] = libsvmread('E:\libsvm\libsvm-3.16\libsvm-3.16\matlab\heart_scale');
model=svmtrain(heart_scale_label,heart_scale_inst);
[predict_label,accuracy]=svmpredict(heart_scale_label,heart_scale_inst,model);
% [predict_label,accuracy]=svmpredict(indian_pines_gt,indian_pines_gaborall(:,:,:,1),model);
clear all;