        tic;
        close all;
        clear all;
        clc;
%         load squaretext;
%         load noisesquaretext;
        look=1;
        yita=1/sqrt(look);%%%%for one-look intensity, ηv=1 for one-look amplitude data, ηv=0.5227 
        Tk=6  ; %%%%%%%%%%%%%%%%%%%% 5 6 7 



        %%%%improved sigma filter%%%%%
%         image='image_Cameraman256.png';
%         image='squaretext.png';
%         im=double(imread(image));
        im=squaretext;
%     im=double(imread(image));
    %     figure
    %     imshow(uint8(im));
        %%%%%%%%%%%%%%%%%%%%%%%%%产生sar图像%%%%%%%%%%%%%%
        load sarnoise_1look.mat;
        nim=im.*sarnoise_1look;
%         point=286.4*ones(3,3);
%         for i=1:256
%             if mod(i,12)==8
%                 nim(127:129,i-1:i+1)=point;
%             end
%         end

%      image='4强度.jpg';
%      nim=double(imread(image));
%         nim=noisesquaretext;

        [M,N]=size(nim);
        n=round(0.98*M*N);
        l=sort(nim(:));
        level=l(n);

        mode=zeros(11,11);
        mode33=zeros(3,3);
        background=zeros(M,N);
        expandim = padarray(nim,[5 5],'symmetric');
        expandbackground = padarray(background,[5 5],'symmetric');
        newim=zeros(M,N);
%       %%%1_look%%% I1    I2   I2-I1  yita                        
        tableI=[0.436,1.92,1.484,0.4057;   %sigma =  0.5
            0.343,2.12,1.868,0.4954;      %         0.6
            0.254,2.582,2.328,0.5911;     %         0.7 
            0.168,3.094,2.926,0.6966;     %         0.8
            0.084,3.941,3.857,0.8191;     %         0.9
            0.043,4.840,4.797,0.8599] ;    %         0.95

    %         %%%2_look%%% I1    I2   I2-I1  yita                        
%         tableI=[0.582,1.548,1.002,0.2763;   %sigma =  0.5
%             0.501,1.755,1.254,0.3388;      %         0.6
%             0.418,1.1972,1.554,0.4062;     %         0.7 
%             0.372,2.260,1.934,0.4801;     %         0.8
%             0.221,2.744,2.523,0.5699;     %         0.9
%             0.152,3.206,3.054,0.6254] ;    %         0.95

    %         %%%3_look%%% I1    I2   I2-I1  yita                        
    %     tableI=[0.652,1.458,0.806,0.2222;   %sigma =  0.5
    %         0.580,1.586,1.006,0.2736;      %         0.6
    %         0.505,1.751,1.246,0.3280;     %         0.7 
    %         0.419,1.965,1.546,0.3892;     %         0.8
    %         0.313,2.320,2.007,0.4624;     %         0.9
    %         0.238,2.656,2.418,0.5084] ;    %         0.95

            %%%4_look%%% I1    I2   I2-I1  yita                        
%         tableI=[0.694,1.385,0.691,0.1921;   %sigma =  0.5
%             0.630,1.495,0.865,0.2348;      %         0.6
%             0.560,1.627,1.067,0.2825;     %         0.7 
%             0.480,1.804,1.324,0.3354;     %         0.8
%             0.378,2.094,1.716,0.3991;     %         0.9
%             0.302,2.360,2.058,0.4391] ;    %         0.95


    %     %%%1_look%%% A1    A2   A2-A1  yita                        
    %     tableA=[0.653997,1.40002,0.746019,0.208349;   %sigma =  0.5
    %         0.578998,1.50601,0.927012,0.255358;      %         0.6
    %         0.496999,1.63201,1.13501,0.305303;     %         0.7 
    %         0.403999,1.79501,1.39101,0.361078;     %         0.8
    %         0.286000,2.04301,1.75701,0.426375;     %         0.9
    %         0.203000,2.25998,2.05698,0.466398] ;    %         0.95
    %     
    %         %%%2_look%%% A1    A2   A2-A1  yita                        
    %     tableA=[0.760,1.263,0.503,0.139021;   %sigma =  0.5
    %         0.705,1.332,0.627,0.169777;      %         0.6
    %         0.643,1.412,0.769,0.206675;     %         0.7 
    %         0.568,1.515,0.947,0.244576;     %         0.8
    %         0.467,1.673,1.206,0.291070;     %         0.9
    %         0.387,1.812,1.425,0.319955] ;    %         0.95
    %     
    %         %%%3_look%%% A1    A2   A2-A1  yita                        
    %     tableA=[0.806,1.21,0.404,0.109832;   %sigma =  0.5
    %         0.760,1.263,0.503,0.138001;      %         0.6
    %         0.708,1.327,0.619,0.163686;     %         0.7 
    %         0.645,1.408,0.763,0.195970;     %         0.8
    %         0.557,1.531,0.974,0.234219;     %         0.9
    %         0.485,1.639,1.154,0.257969] ;    %         0.95
    %     
    %         %%%4_look%%% A1    A2   A2-A1  yita                        
    %     tableA=[0.832,1.179,0.347,0.0894192;   %sigma =  0.5
    %         0.793,1.226,0.433,0.112018;      %         0.6
    %         0.747,1.279,0.532,0.139243;     %         0.7 
    %         0.691,1.347,0.656,0.167771;     %         0.8
    %         0.613,1.452,0.839,0.201036;     %         0.9
    %         0.548,1.543,0.995,0.222048] ;    %         0.95

        %%%%%%%%%%%%%%%%%%强散射点目标标记：
        for i=1:M
            for j=1:N
                exi=i+5;exj=j+5;
                if expandim(exi,exj)>=level
                    mode33=zeros(3,3);
                    k=0;
                    for mi=-1:1
                        for mj=-1:1
                            if expandim(exi+mi,exj+mj)>=level
                                k=k+1;
                                mode33(mi+2,mj+2)=1;
                            end
                        end
                    end
                    if k>=Tk;
                        for mi=-1:1
                            for mj=-1:1
                                if mode33(mi+2,mj+2)==1
                                    expandbackground(exi+mi,exj+mj)=mode33(mi+2,mj+2);
                                    newim(i+mi,j+mj)=nim(i+mi,j+mj);
                                end
                            end
                        end
                    end
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %  j=20;
    %  i=43;
    for i=1:M
        for j=1:N
            exi=i+5;exj=j+5;
            if expandbackground(exi,exj)==0;   %%%%%%%%%%%%%%%%%%%%%%%%%%%%未标记点进行MMSE
                mode33=expandim(exi-1:exi+1,exj-1:exj+1);
                L=reshape(mode33,9,1);
                [seed1,flag]=MMSE(L,expandim(exi,exj),yita);
                sigmarange=tableI(4,1:2)*seed1;
                L1=[];
                size11=0;
                for i11=-5:5
                    for j11=-5:5
                        if (expandim(exi+i11,exj+j11)>=sigmarange(1))&&(expandim(exi+i11,exj+j11)<=sigmarange(2))
                            size11=size11+1;
                            L1(size11)=expandim(exi+i11,exj+j11);
                        end
                    end
                end
                [m,n]=size(L1);
                L1=reshape(L1,m*n,1);
                   if size11==0
 
                       seed2=seed1;
                   else
                       [seed2,flag]=MMSE(L1,expandim(exi,exj),tableI(4,4));
                       
                   end
                         newim(i,j)=seed2;
    %             end
            else
                newim(i,j)=nim(i,j);
            end
        end
    end

    % figure
    % 
    % imshow(uint8(newim));
    % K=PSNR(im,newim)
    % imim=[im nim newim];
    % imshow(uint8(imim))
    % imwrite(uint8(newim),'1Isquarelee3.9836_2.1628_32.8050_39.2557_179.6782.png')
    %%%%%%%%%%%%%均值滤波
    % filterave=fspecial('average',[5 5]);
    % aveim=imfilter(nim,filterave);  %% aveim: use average filter to operate %%
    % figure;title('average filting use 5*5 matrix')
    % aveim=uint8(aveim);
    % imshow(uint8(aveim));
    % imwrite(uint8(aveim),'F:\matlab\zd_text_improved_sigma_filtering\cameramanresultave55.png')


    % 
    % %%%%计算四块的均值%%%%%%%%%
    % image='F:\matlab\zd_text_improved_sigma_filtering\squaretextresult2TK=6.png.png'
%     % im=imread(image);
%     im=newim;
%     A=[mean(reshape(newim(40:89,40:89),1,2500)) ,mean(reshape(newim(40:89,168:217),1,2500)) ,mean(reshape(newim(168:217,40:89),1,2500)) ,mean(reshape(newim(168:217,168:217),1,2500))]
    %%%%%%%%%%%%计算亮点均值
    
%     x=[];
%     for i=1:256
%         if mod(i,12)==8
%             
%             x=cat(1,x,newim(127:129,i-1:i+1));
%             x=cat(1,x,newim(i-1:i+1,127:129)');
%         end
%     end
%     A=mean(x(:))
    %%%%%%%计算背景
    toc;
