function [ indian_pines_gaborsel,f_sel_gt ] = Feature_sel_I( opt_num)
%此函数使用顺序前进法进行特征选择
%输入为需要选出样本的数目（也可改为相邻两次分类的差值阈值）
%此函数在indian_pine.m中调用，需要首先运行IO.m导入矩阵，并且经过gabor_I得到全部gabor特征
%返回一个矩阵indian_pines_gaborsel，是indian_pines_gaborall在方向维上的简化矩阵
%返回向量f_sel，里面存储了选出的方向序号

%！！！！！！！！！此函数会对原始的indian_pines_gaborall变量进行重构，所有不经过特征选择的步骤应在此函数之前执行
%------------------------------------------------------------------------

global indian_pines_gaborall;  %声明所有数据的gabor特征变量

f_sel=[];
f_ori=1:52;
t=0;  %迭代变量，标记选出特征的个数
indian_pines_gaborsel=zeros(145,145,200,1); %特征选择之后的gabor矩阵，结构与indian_pines_gaborall相同，145x145x200xopt_num最后一位（方向维），有所减少
accuracy=zeros(1,52);  %记录每种测试组合的平均正确率
while(t<opt_num)
   
    for k=1:52  %迭代变量，标记未选出特征的个数
        if(find(k==f_ori))
            indian_pines_test=indian_pines_gaborsel;
            indian_pines_test(:,:,:,t+1)=indian_pines_gaborall(:,:,:,k); %将原始特征库中的一个方向数与已经得到的进行组合，得到一个测试gabor矩阵
            time=3;  %平均次数
            for ti=1:time %十次分类取平均,取25%样本率
                if (t==0)  %第一次选，需要3个参数
                    accuracy(k)=accuracy(k)+Kmeans_I_pixel(indian_pines_test,0.25,1);
                else
                    accuracy(k)=accuracy(k)+Kmeans_I_pixel(indian_pines_test,0.25);
                end
            end
            fprintf('%0.2f\n',k);
        end
    end
    accuracy=accuracy./time;   %得到平均值
    order=find(accuracy==max(accuracy)); %得到下一步最优特征
    accuracy(order)=0;  %该特征的准确率重置为0，避免进入下次选择
    t=t+1;  %每选出一个特征order，t++
    f_sel(t)=order; %将选出的特征加入标签矩阵与新gabor矩阵中
    indian_pines_gaborsel(:,:,:,t)=indian_pines_gaborall(:,:,:,order); 
    f_ori(order)=[];  %将特征从原始标签矩阵库中移除
fprintf('%0.2f th feature generated:No.%0.2f\n',t,order);
end

disp('feature selection complete!\n');
save('indian_pines_gaborsel.mat','indian_pines_gaborsel');