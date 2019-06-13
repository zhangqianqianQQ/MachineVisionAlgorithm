function [x, y] = arrange_data(total)
% X = features
% Y = label
x = [];
y = {};
for n = 1:5
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
            
            x = [ x ; x_temp ];
            y = [ y ; y_temp ];
        end
    end
end


