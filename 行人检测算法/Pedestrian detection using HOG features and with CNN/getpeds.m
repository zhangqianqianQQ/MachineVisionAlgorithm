function [curranpeds,currimpeds,currnopeds] = getpeds(anfile,imname)

im = imread(imname);
im = rgb2gray(im);
curranpeds = [];
currimpeds = [];
fid = fopen(anfile);
tline = fgetl(fid);
nu = 1;
while ischar(tline)
    tline = fgetl(fid);
    %disp(tline);
    if strcmp(tline,'-1')
        %nothing
    else
        %strr{nu}=char(tline);
        str = sscanf(char(tline),'%*s %d %d %d %d %d %d %d %d %d %d %d');
        str = str'
        %disp(str);
        ka = waitforbuttonpress;
        if (str(5)~=1)&&(str(3)>20)
            curranpeds = vertcat(curranpeds,str);
            currim = imcrop(im,str(1:4));
            currim = imresize(currim,[96 40]);
            currim = currim(:)';
            currimpeds = vertcat(currimpeds,currim);
        end
        %count1=count1+1;
    end
    nu=nu+1;
end
fclose(fid);
currnopeds = size(curranpeds,1);

end
