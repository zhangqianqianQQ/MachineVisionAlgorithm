%展示16类的gabor特征
%需要先运行Gabor_new.m文件，生成包含所有Gabor特征信息的M_g矩阵
%本程序仅用于展示，之后不构成调用关系，之后无变量依赖

% g_feature=zeros(52,16);
% for dir=1:52
%     g_number=zeros(1,16);
%     for x=1:145
%         for y=1:145
%             if(indian_pines_gt(x,y)~=0)
%                 g_feature(dir,indian_pines_gt(x,y))=g_feature(dir,indian_pines_gt(x,y))+mean(M_g{dir}(x,y,:));
%                 g_number(indian_pines_gt(x,y))=g_number(indian_pines_gt(x,y))+1;   %记录该类别的点数
%             end
%         end
%     end
%     g_feature(dir,:)=g_feature(dir,:)./g_number;
% end

x=1:52;
plot(x,g_feature(:,1),'*');

