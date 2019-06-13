function [DATA, LABEL, INDEX] = write_save_h5(model, input_size,pad_size, I_row, I_high,label, ...
                                             index, savepath, im_extend, varargin )
                                         
switch model
    case 'train'  %%% generate training samples and labels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DATA=zeros(input_size,input_size,I_high,length(label));
        LABEL=label-1;
        count=0;
    
        for j=1:length(index)
            count=count+1;

            img_data=[];
            X=mod(index(j),I_row);
            Y=ceil(index(j)/I_row);
            if X==0
               X=I_row;
            end
            if Y==0
               Y=I_line;
            end
            X_new = X+pad_size;
            Y_new = Y+pad_size;
            X_range = [X_new-pad_size : X_new+pad_size];
      
            Y_range = [Y_new-pad_size : Y_new+pad_size]; 

            img_data=im_extend(X_range,Y_range,:);
            
            
            DATA(:,:,:,count)=img_data;
            
        
        end

%%%%%%%%%%%%%%%    write train.hdf5    %%%%%%%%%%%%%
        order = randperm(count);
        INDEX=index(:,order);
        DATA=DATA(:,:,:,order);
        DATA=permute(DATA,[2 1 3 4]);
        LABEL=LABEL(:,order);
        data=DATA;
        label=LABEL;
        chunksz = 100;
        created_flag = false;
        totalct = 0;

        for batchno = 1:ceil(count/chunksz)
           last_read=(batchno-1)*chunksz;
           if batchno*chunksz>count
              batchdata = data(:,:,:,last_read+1:end); 
              batchlabs = label(:,last_read+1:end); 
           else
              batchdata = data(:,:,:,last_read+1:last_read+chunksz); 
              batchlabs = label(:,last_read+1:last_read+chunksz);
           end

           startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
           curr_dat_sz = store2hdf5(savepath, batchdata, batchlabs, ~created_flag, startloc, chunksz); 
           created_flag = true;
           totalct = curr_dat_sz(end);
        end
        h5disp(savepath);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case 'test'   %%% generate test samples and labels
%%%%%%%%%%%%% generate testing samples and labels  %%%%%%%%%%%%%%%%%%
        
        DATA=zeros(input_size,input_size,I_high,length(label));
        LABEL=label-1;
        count=0;
   
        for j=1:length(index)
            count=count+1;

            img_data=[];
            X=mod(index(j),I_row);
            Y=ceil(index(j)/I_row);
            if X==0
               X=I_row;
            end
            if Y==0
              Y=I_line;
            end
            X_new = X+pad_size;
            Y_new = Y+pad_size;
            X_range = [X_new-pad_size : X_new+pad_size];
      
            Y_range = [Y_new-pad_size : Y_new+pad_size]; 

            img_data=im_extend(X_range,Y_range,:);
            
            
            DATA(:,:,:,count)=img_data;
            
       
        end

%%%%%%%%%%%%%%%%   write test.hdf5 %%%%%%%%%%%%%%%%%%%%%%%%%%%
       order = randperm(count);
       INDEX = index(:,order);
       DATA  = DATA(:,:,:,order);
       DATA  = permute(DATA,[2 1 3 4]);
       LABEL = LABEL(:,order);
       count_batch = 5;
       
       for k=1:count_batch
           count=length(LABEL)/count_batch;
           data=DATA(:,:,:,(k-1)*count+1:k*count);
           label=LABEL(:,(k-1)*count+1:k*count);
           chunksz = 100;
           created_flag = false;
           totalct = 0;
           savepath_test_temp=strcat(savepath,'test',num2str(k),'.h5');
           
           for batchno = 1:ceil(count/chunksz)
               last_read=(batchno-1)*chunksz;
               if batchno*chunksz>count
                    batchdata = data(:,:,:,last_read+1:end); 
                    batchlabs = label(:,last_read+1:end); 
               else
                    batchdata = data(:,:,:,last_read+1:last_read+chunksz); 
                    batchlabs = label(:,last_read+1:last_read+chunksz);
               end

              startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
              curr_dat_sz = store2hdf5(savepath_test_temp, batchdata, batchlabs, ~created_flag, startloc, chunksz); 
              created_flag = true;
              totalct = curr_dat_sz(end);
           end
           h5disp(savepath_test_temp);
       end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
        