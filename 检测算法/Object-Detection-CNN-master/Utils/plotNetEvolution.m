
%% This script plots the loss and accuracy evolution during the 
%%% training of a CNN by Caffe

% Path to the .txt file with the training output
%%% ObjDetectCNN
% file_path = '../Training_Results/output_training_ObjDetection_v1.txt';
% file_path = '../Training_Results/output_training_ObjDetection_finetunning_v2.2.txt';
% file_path = '../Training_Results/output_training_ObjDetection_finetunning_strict_v1.txt';
%%% MammoCNN
% file_path = '../../../MamoCNN/Training_Results/output_training_MammoCNN_v2.txt';
% file_path = '../../../MamoCNN/Training_Results/output_training_lr0-000000001.txt';
% file_path = '../../../MamoCNN/Training_Results/output_training_2-class_lr0-0000001.txt';
% file_path = '../../../MamoCNN/Training_Results/output_training_2-class_lr0-000001_3conv.txt';
% file_path = '../../../MamoCNN/Training_Results/output_training_2-class_lr0-0000001_2conv.txt';
% file_path = '../../../MamoCNN/Training_Results/output_training_5-class_finetunning_lr0-0000001.txt';
%%% FoodCNN
% file_path = '../../../FoodCNN/Training_Results/output_training_finetunning_v1.txt';
% file_path = '../../../FoodCNN/Training_Results/output_training_v1.txt';
% file_path = '../../../FoodCNN/Training_Results/output_training_finetunning_v2.txt';
% file_path = '../../../FoodCNN/Training_Results/output_training_finetunning_v2_1.txt';
%%% InformativeImagesDetectorCNN
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_InformativeCNN_CV1_v1.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_InformativeCNN_CV1_v2.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_HybridPlaces_InformativeCNN_CV1_v1.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_CNDS_InformativeCNN_CV1_v1.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_CNDS_InformativeCNN_CV1_v2.txt';
file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_CNDS_InformativeCNN_CV1_v3.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_InformativeCNN_CV2_v1.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_InformativeCNN_CV3_v1.txt';
% file_path = '../../../InformativeImagesDetector/Training_Results/output_training_finetunning_InformativeCNN_CV4_v1.txt';
%%% MNIST Test
% file_path = '../../../MNIST_tests/Training_Results/output_training_v1.txt';
% file_path = '../../../MNIST_tests/Training_Results/output_training_mod_v1.txt';
% file_path = '../../../MNIST_tests/Training_Results/output_training_mod_v2.txt';
% file_path = '../../../MNIST_tests/Training_Results/output_training_mod_v2_2-layers.txt';
% file_path = '../../../MNIST_tests/Training_Results/output_training_mod_v2_4-layers.txt';

test_accuracies = {'accuracy', 'accuracy_DSN_conv3'};
% test_accuracies = {'accuracy'};
% test_accuracies = {'prob'};

test_losses = {'loss', 'loss_DSN_conv3'};
% test_losses = {'loss'};

% Only pick 1 sample for each N
Nsubsample_loss = 5;
% Nsubsample_loss = 5;
Nsubsample_axis = 50;
% Nsubsample_axis = 50;
Nsubsample_accuracy = 1;

% Training loss, Test loss, Test accuracy and Max Accuracy colours
colours = {'k', 'winter', 'winter', 'r'};
lines_width = 2;

%% Get colours

%%% Test loss
test_loss_c = colormap(colours{2});
close(gcf);
test_loss_c = test_loss_c(round(linspace(1,size(test_loss_c,1)/2, length(test_losses))), :);

%%% Test accuracy
test_acc_c = colormap(colours{3});
close(gcf);
test_acc_c = test_acc_c(round(linspace(size(test_acc_c,1)-20,size(test_acc_c,1), length(test_accuracies))), :);

%% Read file
data = fileread(file_path);

%% Prepare figure
f = figure;
hold on;

%% Get training progress
loss = [];
loss_iter = [];

%%% Training loss
find_loss = regexp(data, 'Train net output #0: loss = ', 'split');
nSplits = length(find_loss);
for i = 2:nSplits
    this_loss = regexp(find_loss{i}, ' ', 'split');
    loss = [loss str2num(this_loss{1})];
end

%%% Training iteration
find_loss_iter = regexp(data, 'Iteration ', 'split');
nSplits = length(find_loss_iter);
for i = 2:nSplits
    this_loss_iter = regexp(find_loss_iter{i}, ', loss = ', 'split');
    if(length(this_loss_iter) > 1)
        loss_iter = [loss_iter str2num(this_loss_iter{1})];
    end
end

if(length(loss) == length(loss_iter)-1)
    loss_iter = loss_iter(1:end-1);
end

%% Get testing progress
accuracy = [];
loss_test = [];
accuracy_loss_iter = [];

%%% Testing accuracy
nTestAcc = length(test_accuracies);
for n = 1:nTestAcc
    find_accuracy = regexp(data, ['Test net output #.: ' test_accuracies{n} ' = '], 'split');
    nSplits = length(find_accuracy);
    for i = 2:nSplits
        this_accuracy = regexp(find_accuracy{i}, '\n', 'split');
        accuracy(n,i-1) = str2num(this_accuracy{1});
    end
end

%%% Testing loss
nTestLoss = length(test_losses);
for n = 1:nTestLoss
    find_loss_test = regexp(data, ['Test net output #.: ' test_losses{n} ' = '], 'split');
    nSplits = length(find_loss_test);
    for i = 2:nSplits
        this_loss_test = regexp(find_loss_test{i}, ' ', 'split');
        loss_test(n,i-1) = str2num(this_loss_test{1});
    end
end

%%% Testing iteration
find_accuracy_iter = regexp(data, ', Testing net (#0', 'split');
nSplits = length(find_accuracy_iter);
for i = 1:nSplits-1
    this_accuracy_iter = regexp(find_accuracy_iter{i}, 'Iteration ', 'split');
    accuracy_loss_iter = [accuracy_loss_iter str2num(this_accuracy_iter{end})];
end

%% Plot loss progress
data_plotted = {};

plot(loss_iter(1:Nsubsample_loss:end), loss(1:Nsubsample_loss:end), 'Color', colours{1}, 'LineWidth', lines_width);
data_plotted = {data_plotted{:}, 'Training loss'};

%% Plot accuracy progress
for n = 1:nTestLoss
    plot(accuracy_loss_iter(1:Nsubsample_accuracy:end), loss_test(n, 1:Nsubsample_accuracy:end), 'Color', test_loss_c(n,:), 'LineWidth', lines_width);
    data_plotted = {data_plotted{:}, ['Test ' strjoin(regexp(test_losses{n}, '_', 'split'), ' ')]};
end
for n = 1:nTestAcc
    plot(accuracy_loss_iter(1:Nsubsample_accuracy:end), accuracy(n, 1:Nsubsample_accuracy:end), 'Color', test_acc_c(n,:), 'LineWidth', lines_width);
    data_plotted = {data_plotted{:}, ['Test ' strjoin(regexp(test_accuracies{n}, '_', 'split'), ' ')]};
end

%% Plot max accuracy horizontal line
plot([0 loss_iter(end)], [1 1], 'Color', colours{4}, 'LineWidth', lines_width);
data_plotted = {data_plotted{:}, 'Max Accuracy'};

%% Plot max accuracy and min test loss
for n = 1:nTestAcc
    [val, pos] = max(accuracy(n,:));
    scatter(accuracy_loss_iter(pos), val, [], ...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor',test_acc_c(n,:),...
                    'LineWidth',1.5);
    text(accuracy_loss_iter(pos)+0.02, val, sprintf('acc %0.3f\niter %d', val, accuracy_loss_iter(pos)), 'FontSize', 12);
end

for n = 1:nTestLoss
    [val, pos] = min(loss_test(n,:));
    scatter(accuracy_loss_iter(pos), val, [], ...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor',test_loss_c(n,:),...
                    'LineWidth',1.5);
    text(accuracy_loss_iter(pos)+0.02, val, sprintf('loss %0.3f\niter %d', val, accuracy_loss_iter(pos)), 'FontSize', 12);
end
    
%% Plot general info
xticklabel_rotate(loss_iter(1:Nsubsample_axis:end), 45);
legend(data_plotted,3);
max_val_loss = max([max(loss) max(loss_test) 1]);
ylim([0 max_val_loss]);
set(gca, 'YTick', linspace(0, max_val_loss, 21));
xlabel('Iterations');
grid on;
