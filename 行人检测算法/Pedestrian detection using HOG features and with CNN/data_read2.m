%
%
%
close all;
imdirname = 'D:/studies/DDP/Datasets/data-USA/images';
andirname = 'D:/studies/DDP/Datasets/data-USA/annotations';
imdir = dir(imdirname);
fprintf('Begin\n');
count = 0;
count1 = 0;
anpeds = [];
impeds = [];
i=1;
while i<=(length(imdir)-2)
    % Entered folder containing set##
    subname1 = imdir(i+2).name;
    imsubname1 = strcat(imdirname,'/',subname1);
    imsubdir1 = dir(imsubname1);
    j=1;
    while j<=(length(imsubdir1)-2)
        % Entered folder containing V###
        subname2 = imsubdir1(j+2).name;
        imsubname2 = strcat(imsubname1,'/',subname2);
        imsubdir2 = dir(imsubname2);
        k=1;
        while k <= (length(imsubdir2)-2)
            % images found
            subname3 = imsubdir2(k+2).name;
            subname33 = subname3(1:length(subname3)-4);
            imname = strcat(imsubname2,'/',subname3);
            anfile = strcat(andirname,'/',subname1,'/',subname2,'/',subname33,'.txt');
            
%             [curranpeds,currimpeds,currnopeds] = getpeds(anfile,imname);
            %----image code----
%             im = imread(imname);
%             curranpeds = [];
%             currimpeds = [];
%             fid = fopen(anfile);
%             tline = fgetl(fid);
%             strr{1}=tline;
%             nu = 1;
%             while ischar(tline)
%                 tline = fgetl(fid);
%                 %disp(tline);
%                 if strcmp(tline,'-1')
%                     %nothing
%                 else
%                     %strr{nu}=char(tline);
%                     str = sscanf(char(tline),'%*s %d %d %d %d %d %d %d %d %d %d %d');
%                     disp(str');
%                     curranpeds = vertcat(curranpeds,str');
%                     count1=count1+1;
%                 end
%                 nu=nu+1;
%             end
%             fclose(fid);
%             tline='0';
%             currnopeds = size(curranpeds,1);
%             
            %for currno=1:currnopeds
            
            im = imread(imname);
            im = rgb2gray(im);
            curranpeds = [];
            currimpeds = [];
            fid = fopen(anfile);
            tline = fgetl(fid);
            nu = 1;
            while ischar(tline)
                tline = fgetl(fid);
                disp(tline);
                if strcmp(tline,'-1')
                    %nothing
                else
                    str = sscanf(char(tline),'%*s %d %d %d %d %d %d %d %d %d %d %d');
                    disp(str);
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

            
            %---endimagecode---
            if currnopeds ~=0
                figure(1);hold on;
                imshow(im);
                for noim=1:currnopeds
                    rectangle('Position',curranpeds(noim,1:4),'EdgeColor','r','LineWidth',1);
                end
                disp(curranpeds);
                count = count+1;
                
            end
            k = k+1;
            
        end
        j = j+1;
    end
    i = i+1;
end
fprintf('End!\n');