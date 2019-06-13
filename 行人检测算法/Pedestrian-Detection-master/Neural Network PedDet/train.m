function [model, loss, accuracy_array, test_loss,test_accuracy_array] = train(model,input,label,params,loss_thresh)
% Learning rate
if isfield(params,'learning_rate') lr = params.learning_rate;
else lr = .01; end
% Weight decay
if isfield(params,'weight_decay') wd = params.weight_decay;
else wd = .0005; end
% Batch size
if isfield(params,'batch_size') batch_size = params.batch_size;
else batch_size = 128; end

if isfield(params,'save_file') save_file = params.save_file;
else save_file = 'model.mat'; end

% update_params will be passed to your update_weights function.
% This allows flexibility in case you want to implement extra features like momentum.
%pre-set the start vel_W and vel_b
figure
for i = 1:size(model.layers,1)
    vel_W{i} = zeros(size(model.layers(i).params.W));
    vel_b{i} = zeros(size(model.layers(i).params.b));
end
rate_deccease = 0.9;
MT=0.95;
update_params = struct('learning_rate',lr,'weight_decay',wd,'momentum',MT);
num_batches=size(input,4);%ize(input,4)
accuracy=0;
test_accuracy=0;
accuracy_array=[];
test_accuracy_array=[];
loss=[];
test_loss=[];
iteration=1;
iterchange=[0];
%while accuracy<accuracy_thresh || loss(end)>0.04 || test_accuracy<accuracy_thresh ||test_loss(end)>0.04
while iteration<10 || loss(end)>loss_thresh || test_loss(end)>loss_thresh
    %choose random batcheds
    batch_idx=randperm(num_batches,batch_size);
    batches=input(:,:,:,batch_idx);labels=label(batch_idx);
    [output,activations]=inference(model,batches);
    [~,result]=max(output,[],1);
    result=result(:);
    [loss(end+1),dv_output]=loss_crossentropy(output,labels,[],1);
    accuracy=sum(result==labels)/length(result);
    accuracy_array=[accuracy_array,accuracy];
    %using cross validate to compute test accuracy
    test_idx=randperm(num_batches,300);
    test_batch=input(:,:,:,test_idx);test_labels=label(test_idx);
    [output,~]=inference(model,test_batch);
    [~,test_result]=max(output,[],1);
    test_result=test_result(:);
    [test_loss(end+1),~]=loss_crossentropy(output,test_labels,[],1);
    test_accuracy=sum(test_result==test_labels)/300;
    test_accuracy_array=[test_accuracy_array,test_accuracy];
    
    %update gradient
    [grad]=calc_gradient(model, batches,activations,dv_output);
    [model,vel_W,vel_b]=update_weights(model,grad,update_params,vel_W,vel_b);
    save(save_file,'model','loss','accuracy','update_params');
    fprintf('In the %d iteration, the trainingaccuracy:%f, train_loss:%f, test_accuracy:%f. test_loss:%f, learning rate is %f.\n',iteration ,accuracy ,loss(end), test_accuracy,test_loss(end),update_params.learning_rate);
    %We want to decrease the learning rate when the accuracy change slowly within step;
    if iteration>20
        temp1=mean(accuracy_array(end-9:end));
        temp2=mean(accuracy_array(end-19:end-10));
        if abs((temp1-temp2))/temp1<0.001 && iteration-iterchange(end)>3
            update_params.learning_rate = update_params.learning_rate * rate_deccease;
            iterchange=[iterchange,iteration];
            disp('lr change')
        end
    end
    %print the test accuracy
    if mod(iteration,10)==0
        subplot(2,2,1)
        plot(loss);
        title(['training loss in ' num2str(iteration) ' iterations']);
        subplot(2,2,2)
        plot(accuracy_array);
        title(['training accuracy in ' num2str(iteration) ' iterations']);
        subplot(2,2,3)
        plot(test_loss)
        title(['test loss in ' num2str(iteration) ' iterations']);
        subplot(2,2,4)        
        plot(test_accuracy_array);
        title(['test accuracy in ' num2str(iteration) ' iterations']);
        drawnow
    end
    iteration = iteration+1;
end