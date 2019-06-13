function [ ] = Random_svm_I( rate )
%此函数传递一个比例rate，按比例生成libsvm需要格式的测试文件

[sel_label,class_num]=Random_I(rate); %调用random_I函数产生一定比例的样本，其中label为选中标签，class_NUM为每类样本的个数

for x=1:145
    for y=1:145
        fid=fopen('svm_data','a');  %打开/创建文件并在文件尾部加入数据
        if ( (sel_label==1)&&fid )
              %写入数据
            fclose(fid);
        end
    end
end

end

