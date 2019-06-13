function [Img1_KLT_Outlier Img2_KLT_Outlier] = GetOutliers(Img1_KLT,Img2_KLT,ImgPair_MV)

[row1 col1] = size(Img1_KLT.R1_p');
Img1_KLT_Outlier.R1_NUM = 0;
Img2_KLT_Outlier.R1_NUM = 0;
if ImgPair_MV.R1_hasF == 1
    for i = 1:col1
        if CheckIn(i,ImgPair_MV.R1_in) == 0
            Img1_KLT_Outlier.R1_NUM = Img1_KLT_Outlier.R1_NUM + 1;
            Img2_KLT_Outlier.R1_NUM = Img2_KLT_Outlier.R1_NUM + 1;
            Img1_KLT_Outlier.R1_p(Img1_KLT_Outlier.R1_NUM,:) = Img1_KLT.R1_p(i,:);
            Img2_KLT_Outlier.R1_p(Img2_KLT_Outlier.R1_NUM,:) = Img2_KLT.R1_p(i,:);
        end
    end
end

[row2 col2] = size(Img1_KLT.R2_p');
Img1_KLT_Outlier.R2_NUM = 0;
Img2_KLT_Outlier.R2_NUM = 0;
if ImgPair_MV.R2_hasF == 1
    for i = 1:col2
        if CheckIn(i,ImgPair_MV.R2_in) == 0
            Img1_KLT_Outlier.R2_NUM = Img1_KLT_Outlier.R2_NUM + 1;
            Img2_KLT_Outlier.R2_NUM = Img2_KLT_Outlier.R2_NUM + 1;
            Img1_KLT_Outlier.R2_p(Img1_KLT_Outlier.R2_NUM,:) = Img1_KLT.R2_p(i,:);
            Img2_KLT_Outlier.R2_p(Img2_KLT_Outlier.R2_NUM,:) = Img2_KLT.R2_p(i,:);
        end
    end
end

[row3 col3] = size(Img1_KLT.R3_p');
Img1_KLT_Outlier.R3_NUM = 0;
Img2_KLT_Outlier.R3_NUM = 0;
if ImgPair_MV.R3_hasF == 1        
    for i = 1:col3
        if CheckIn(i,ImgPair_MV.R3_in) == 0
            Img1_KLT_Outlier.R3_NUM = Img1_KLT_Outlier.R3_NUM + 1;
            Img2_KLT_Outlier.R3_NUM = Img2_KLT_Outlier.R3_NUM + 1;
            Img1_KLT_Outlier.R3_p(Img1_KLT_Outlier.R3_NUM,:) = Img1_KLT.R3_p(i,:);
            Img2_KLT_Outlier.R3_p(Img2_KLT_Outlier.R3_NUM,:) = Img2_KLT.R3_p(i,:);
        end
    end
end

[row4 col4] = size(Img1_KLT.R4_p');
Img1_KLT_Outlier.R4_NUM = 0;
Img2_KLT_Outlier.R4_NUM = 0;
if ImgPair_MV.R4_hasF == 1
    for i = 1:col4
        if CheckIn(i,ImgPair_MV.R4_in) == 0
            Img1_KLT_Outlier.R4_NUM = Img1_KLT_Outlier.R4_NUM + 1;
            Img2_KLT_Outlier.R4_NUM = Img2_KLT_Outlier.R4_NUM + 1;
            Img1_KLT_Outlier.R4_p(Img1_KLT_Outlier.R4_NUM,:) = Img1_KLT.R4_p(i,:);
            Img2_KLT_Outlier.R4_p(Img2_KLT_Outlier.R4_NUM,:) = Img2_KLT.R4_p(i,:);
        end
    end
end

[row5 col5] = size(Img1_KLT.R5_p');
Img1_KLT_Outlier.R5_NUM = 0;
Img2_KLT_Outlier.R5_NUM = 0;
if ImgPair_MV.R5_hasF == 1
    for i = 1:col5
        if CheckIn(i,ImgPair_MV.R5_in) == 0
            Img1_KLT_Outlier.R5_NUM = Img1_KLT_Outlier.R5_NUM + 1;
            Img2_KLT_Outlier.R5_NUM = Img2_KLT_Outlier.R5_NUM + 1;
            Img1_KLT_Outlier.R5_p(Img1_KLT_Outlier.R5_NUM,:) = Img1_KLT.R5_p(i,:);
            Img2_KLT_Outlier.R5_p(Img2_KLT_Outlier.R5_NUM,:) = Img2_KLT.R5_p(i,:);
        end
    end
end

[row6 col6] = size(Img1_KLT.R6_p');
Img1_KLT_Outlier.R6_NUM = 0;
Img2_KLT_Outlier.R6_NUM = 0;
if ImgPair_MV.R6_hasF == 1
    for i = 1:col6
        if CheckIn(i,ImgPair_MV.R6_in) == 0
            Img1_KLT_Outlier.R6_NUM = Img1_KLT_Outlier.R6_NUM + 1;
            Img2_KLT_Outlier.R6_NUM = Img2_KLT_Outlier.R6_NUM + 1;
            Img1_KLT_Outlier.R6_p(Img1_KLT_Outlier.R6_NUM,:) = Img1_KLT.R6_p(i,:);
            Img2_KLT_Outlier.R6_p(Img2_KLT_Outlier.R6_NUM,:) = Img2_KLT.R6_p(i,:);
        end
    end
end

[row7 col7] = size(Img1_KLT.R7_p');
Img1_KLT_Outlier.R7_NUM = 0;
Img2_KLT_Outlier.R7_NUM = 0;
if ImgPair_MV.R7_hasF == 1
    for i = 1:col7
        if CheckIn(i,ImgPair_MV.R7_in) == 0
            Img1_KLT_Outlier.R7_NUM = Img1_KLT_Outlier.R7_NUM + 1;
            Img2_KLT_Outlier.R7_NUM = Img2_KLT_Outlier.R7_NUM + 1;
            Img1_KLT_Outlier.R7_p(Img1_KLT_Outlier.R7_NUM,:) = Img1_KLT.R7_p(i,:);
            Img2_KLT_Outlier.R7_p(Img2_KLT_Outlier.R7_NUM,:) = Img2_KLT.R7_p(i,:);
        end
    end
end

[row8 col8] = size(Img1_KLT.R8_p');
Img1_KLT_Outlier.R8_NUM = 0;
Img2_KLT_Outlier.R8_NUM = 0;
if ImgPair_MV.R8_hasF == 1
    for i = 1:col8
        if CheckIn(i,ImgPair_MV.R8_in) == 0
            Img1_KLT_Outlier.R8_NUM = Img1_KLT_Outlier.R8_NUM + 1;
            Img2_KLT_Outlier.R8_NUM = Img2_KLT_Outlier.R8_NUM + 1;
            Img1_KLT_Outlier.R8_p(Img1_KLT_Outlier.R8_NUM,:) = Img1_KLT.R8_p(i,:);
            Img2_KLT_Outlier.R8_p(Img2_KLT_Outlier.R8_NUM,:) = Img2_KLT.R8_p(i,:);
        end
    end
end

[row9 col9] = size(Img1_KLT.R9_p');
Img1_KLT_Outlier.R9_NUM = 0;
Img2_KLT_Outlier.R9_NUM = 0;
if ImgPair_MV.R9_hasF == 1
    for i = 1:col9
        if CheckIn(i,ImgPair_MV.R9_in) == 0
            Img1_KLT_Outlier.R9_NUM = Img1_KLT_Outlier.R9_NUM + 1;
            Img2_KLT_Outlier.R9_NUM = Img2_KLT_Outlier.R9_NUM + 1;
            Img1_KLT_Outlier.R9_p(Img1_KLT_Outlier.R9_NUM,:) = Img1_KLT.R9_p(i,:);
            Img2_KLT_Outlier.R9_p(Img2_KLT_Outlier.R9_NUM,:) = Img2_KLT.R9_p(i,:);
        end
    end
end