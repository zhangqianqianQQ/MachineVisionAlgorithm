function [Model2] = train()
    [X] = LoadImages();
    [Y] = LoadLabels();
    [M,P] = GetMP(X,Y);
    
    field1 = 'M';
    field2 = 'P';
    Model2 = struct(field1,M,field2,P);
    save('Model2.mat','Model2');
end