function [ element ] = getElementXML( txt, id )

    try
        element = regexp(txt, ['<' num2str(id) '>'], 'split');
        element = regexp(element{2}, ['</' num2str(id) '>'], 'split');
        element = element{1};
    catch
        if(strcmp(id, 'truncated'))
            element = '-1';
        else
            error(['.XML ERROR: field ' id ' not found.']);
        end
    end

end

