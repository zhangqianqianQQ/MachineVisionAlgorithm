function output = CheckIn(input,array)
[a_rows,a_cols] = size(array);
output = 0;
for i = 1:a_cols
    if input == array(i)
        output = 1;
    end
end