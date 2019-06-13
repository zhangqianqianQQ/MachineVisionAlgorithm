function [x, y, accuracy,test_labels, confusion_matrix] = validate( total, model, method)
% X = features
% Y = label
x = [];
y = {};
for n = 1:length(total)-1
    display(['Reading img',num2str(n)])
    for i = 1:8
        for j = 1:8
            y_temp = total{n+1,3}{i,j};
            if strcmp(y_temp,'')
                continue;
            end           
        
            fields = fieldnames(total{n+1,2}{i,j});
            x_temp = zeros(1,length(fields));
            for f = 1:length(fields)
                x_temp(f) = [getfield(total{n+1,2}{i,j},fields{f})];
            end
         
            y = [ y ; y_temp ];
            x = [ x ; x_temp];
        end
    end
end

load('pca_coeff.mat')

if strcmp(method,'naive')
    test_labels = predict(model,x);
end;
if strcmp(method,'pca')
    pca_x =  x * pca_coeff;
    test_labels = predict(model,pca_x);    
end


count = 0;
for i = 1:length(test_labels)
    if strcmp(test_labels(i),y(i))
        count = count + 1;
    end
end

classifiers = unique(y);
confusion_matrix = cell(length(classifiers)+1,length(classifiers)+1);
confusion_values = zeros(length(classifiers), length(classifiers));
for i = 1:length(classifiers)
    confusion_matrix{i+1,1} = classifiers(i);
    confusion_matrix{1,i+1} = classifiers(i);
end
for i = 2:(length(classifiers)+1)
    for j = (2:length(classifiers)+1)
        for instance = 1:length(y)
            if strcmp(y{instance},confusion_matrix{i,1}) && strcmp(test_labels{instance},confusion_matrix{1,j})
                confusion_values(i-1,j-1) = confusion_values(i-1,j-1) + 1;
            end
        end
    end
end

for i = 2:(length(classifiers)+1)
    for j = (2:length(classifiers)+1)
        confusion_matrix{i,j} = confusion_values(i-1,j-1);
    end
end

end




