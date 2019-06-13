function locations = sample_grid_location(imgsz, sample_step)

if(length(sample_step)==1)
    sample_step = [sample_step,sample_step];
end

imgh = imgsz(1);
imgw = imgsz(2);

[x,y]= meshgrid(3:sample_step(1):imgw,3:sample_step(2):imgh);


locations = [x(:),y(:)];
