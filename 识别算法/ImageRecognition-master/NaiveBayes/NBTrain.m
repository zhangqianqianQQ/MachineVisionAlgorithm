%Function takes in Features matrix and Labels
%Computes the class probility P
%The Mean matrix M
%The variance matrix V
function [P,M,V] = NBTrain(Feats,Labels)

X1 = [];X2 = [];X3 = [];X4 = [];X5 = [];X6 = [];X7 = [];X8 = [];X9 = [];X0 = [];
P = zeros(10,1);
    for i = 1:size(Labels,1)
        if (Labels(i) == 0)
            X0 = vertcat(X0,Feats(i,:));
        elseif (Labels(i) == 1)
            X1 = vertcat(X1,Feats(i,:));
         elseif (Labels(i) == 2)
            X2 = vertcat(X2,Feats(i,:));
         elseif (Labels(i) == 3)
            X3 = vertcat(X3,Feats(i,:));
         elseif (Labels(i) == 4)
            X4 = vertcat(X4,Feats(i,:));
         elseif (Labels(i) == 5)
            X5 = vertcat(X5,Feats(i,:));
         elseif (Labels(i) == 6)
            X6 = vertcat(X6,Feats(i,:));
         elseif (Labels(i) == 7)
            X7 = vertcat(X7,Feats(i,:));
         elseif (Labels(i) == 8)
            X8 = vertcat(X8,Feats(i,:));
         elseif (Labels(i) == 9)
            X9 = vertcat(X9,Feats(i,:));
        end
        P(Labels(i)+1) = P(Labels(i)+1) + 1;
    end
    
    
M0 = mean(X0,1); V0 = var(X0,1);     
M1 = mean(X1,1); V1 = var(X1,1);
M2 = mean(X2,1); V2 = var(X2,1);
M3 = mean(X3,1); V3 = var(X3,1);
M4 = mean(X4,1); V4 = var(X4,1);
M5 = mean(X5,1); V5 = var(X5,1);
M6 = mean(X6,1); V6 = var(X6,1);
M7 = mean(X7,1); V7 = var(X7,1);
M8 = mean(X8,1); V8 = var(X8,1);
M9 = mean(X9,1); V9 = var(X9,1);
M = vertcat(M0,M1,M2,M3,M4,M5,M6,M7,M8,M9);
V = vertcat(V0,V1,V2,V3,V4,V5,V6,V7,V8,V9);

end