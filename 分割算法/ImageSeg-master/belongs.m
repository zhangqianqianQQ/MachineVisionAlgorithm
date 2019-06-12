function ret = belongs(element, array)
    s = sum(find(element==array));
    if s==0
        ret = false;
    else
        ret = true;
    end
end