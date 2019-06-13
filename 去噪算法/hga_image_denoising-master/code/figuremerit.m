function fom = figuremerit(ideal,detected)

    Ni = numel(find(ideal == 1));
    Nd = numel(find(detected == 1));
    
    [h w c] = size(ideal);

    alpha = 1/9;
    sum = 0.0;
    for r = 1:h
        for c = 1:w
            if (detected(r,c) == 1)
                dist = distance(ideal,detected,r,c)^2;
                sum = sum + (1/(1+alpha*dist));
            end
        end
    end

    fom = (1/max(Ni,Nd))*sum;

    
function d = distance(ideal,detected,rind,cind)

    [h w c] = size(ideal);

    diff  = 1;
    found = 0;
    d = 10.0^100;

    if (ideal(rind,cind) == detected(rind,cind))
        d     = 0.0; 
        found = 1;
    end

    left   = cind - diff;
    right  = cind + diff;
    top    = rind - diff;
    bottom = rind + diff;
    while (~found)
    
        for c = left:right
            if ((top >= 1) && (c >= 1) && (c <= w))
                if (ideal(top,c) == detected(rind,cind))
                    tmp = sqrt((top-rind)^2 + (c-cind)^2);
                    found = 1;

                    if (tmp < d)
                        d = tmp;
                    end
                end
            end
        end
        
        for c = left:right
            if ((bottom <= h) && (c >= 1) && (c <= w))
                if (ideal(bottom,c) == detected(rind,cind))
                    tmp = sqrt((bottom-rind)^2 + (c-cind)^2);
                    found = 1;

                    if (tmp < d)
                        d = tmp;
                    end
                end
            end
        end
        
        for r = top+1:bottom-1
            if ((left >= 1) && (r >= 1) && (r <= h))
                if (ideal(r,left) == detected(rind,cind))
                    tmp = sqrt((r-rind)^2 + (left-cind)^2);
                    found = 1;

                    if (tmp < d)
                        d = tmp;
                    end
                end
            end
        end
        
        for r = top+1:bottom-1
            if ((right <= w) && (r >= 1) && (r <= h))
                if (ideal(r,right) == detected(rind,cind))
                    tmp = sqrt((r-rind)^2 + (right-cind)^2);
                    found = 1;

                    if (tmp < d)
                        d = tmp;
                    end
                end
            end
        end

        diff = diff + 1;
        left   = cind - diff;
        right  = cind + diff;
        top    = rind - diff;
        bottom = rind + diff;
        if ((left < 1) && (right > w) && (top < 1) && (bottom > h))
            found = 1;
        end
    end

