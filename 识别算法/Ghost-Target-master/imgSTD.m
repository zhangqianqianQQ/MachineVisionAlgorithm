function data = imgSTD(img)
    data = struct('intensity',[],'red',[],'green',[],'blue',[],'mean_range',[],'std_range',[],'mean_std',[],'std_std',[],'mean_entropy',[]);
    dim = size(img,1) / 4;
    for j = 1:4
        xend = j*dim;
        xstart = xend - 3;
        for m = 1:4
            
            intensity = [];
            red = [];
            green = [];
            blue = [];
            mean_range = [];
            std_range = [];
            mean_std = [];
            std_std = [];
            mean_entropy = [];
            
            yend = m*dim;
            ystart = yend - dim + 1;
            for k = xstart:xend
                for l = ystart:yend
                    intensity = [intensity img{k,l}.intensity];
                    red = [red img{k,l}.red];
                    green = [green img{k,l}.green];
                    blue = [blue img{k,l}.blue];
                    mean_range = [mean_range img{k,l}.mean_range];
                    std_range = [std_range img{k,l}.std_range];
                    mean_std = [mean_std img{k,l}.mean_std];
                    std_std = [std_std img{k,l}.std_std];
                    mean_entropy = [mean_entropy img{k,l}.mean_entropy];
                end
            end
            data.intensity = [data.intensity std(intensity)];
            data.red = [data.red std(red)];
            data.green = [data.green std(green)];
            data.blue = [data.blue std(blue)];
            data.mean_range = [data.mean_range std(mean_range)];
            data.std_range = [data.std_range std(std_range)];
            data.mean_std = [data.mean_std std(mean_std)];
            data.std_std = [data.std_std std(std_std)];
            data.mean_entropy = [data.mean_entropy std(mean_entropy)];
        end
    end
end