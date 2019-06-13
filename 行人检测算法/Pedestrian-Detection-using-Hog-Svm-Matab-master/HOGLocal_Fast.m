function [vector]=HOGLocal_Fast(SATHisBin, CellS, BlockS, Bin, StepCells)
%% Giai thich
% SATHisBin la mot Cells (gom co H hang, va W cot), moi phan tu cua no gom
% Bin phan tu (tuc la Bin cot Histogram. 
%
%%     Initial for demo
%     clear
%     CellS=6; BlockS=3; Bin=9;StepCells=1;
%     Abs=true;
%     Im=rgb2gray(imread('image(14).jpg'));
%% HET Demo
    [H,W]=size(SATHisBin); 
    YH=ceil(H/CellS)-BlockS+1; % So cac Diem Block co the Y
    XW=ceil(W/CellS)-BlockS+1; % So cac Diem Block co the X
    % Tinh toan do cua cac Blocks trong anh
    YLocBlock=1:CellS:H;
    XLocBlock=1:CellS:W;
    % Xu ly truong hop bien
    HTemp=length(YLocBlock);
    YLocBlock(HTemp)=H-CellS+1;
    WTemp=length(XLocBlock);
    XLocBlock(WTemp)=W-CellS+1;
    %
    NumItemBlock=BlockS*BlockS*Bin; % Number Bin phan tu trong 1 Block
    % End: Tinh toan do cua cac Cells trong Blocks
    % Tinh toan do cua cac Blocks
    %% Them vao 1 hang 0 va 1 cot 0 de de du ly
%     AAA=SATHisBin;
    [H1,W1]=size(SATHisBin);
    SATHisBin(2:H1+1,2:W1+1)=SATHisBin;
    SATHisBin(1,:)={zeros(Bin,1)};
    SATHisBin(:,1)={zeros(Bin,1)};
    %% Xu ly block cuoi cung, khi anh khong co chan Block, ben phai dich lai vai cell de du Block.
    IndY=1:StepCells:YH;
    if IndY(length(IndY))<YH
        IndY=[IndY  YH];
    end
    IndX=1:StepCells:XW;
    if IndX(length(IndX))<XW
        IndX=[IndX  XW];
    end
    %% Khoi tao Vector
    Number=length(IndY)*length(IndX)*NumItemBlock;
    HOGVec=zeros(Number,1);
    HisBin=zeros(NumItemBlock,1);
    LocItemVec=1;% Phan tu dau tien
    h1=CellS;w1=CellS;
    %% Phan chuong trinh tinh Histogram cho cac Cell va Block trong toan anh
    for i=1:length(IndY)                         % Number block trong anh theo chieu Y
        for j=1:length(IndX)                     %Number block trong anh theo chieu X
            LocItemBlock=1;% Khoi tao gia tri tai phan tu thu nhat trong Block
            for t=1:BlockS                      % Number Cells trong Block theo chieu Y
                y1=YLocBlock(IndY(i)+t-1);      %+YLocCell(t)-1;  % Xac dinh toa do theo chieu Y
                for k=1:BlockS                  % Number Cells trong Block theo chieu X
                    x1=XLocBlock(IndX(j)+k-1);     %+XLocCell(k)-1; % Xac dinh toa do theo chieu Y
                    HOGTemp=SATHisBin{y1+h1,x1+w1}+SATHisBin{y1,x1};
                    HOGTemp=HOGTemp-SATHisBin{y1,x1+w1}-SATHisBin{y1+h1,x1};
                    % Tinh toa do cua Phan tu hien tai
                    HisBin(LocItemBlock:LocItemBlock+Bin-1)=HOGTemp(:);
                    LocItemBlock=LocItemBlock+Bin;
                    % Calculate HOG trong Cells
                end
            end
            HisBin=sqrt(HisBin/(norm(HisBin)+10^-5));
            HOGVec(LocItemVec:LocItemVec+NumItemBlock-1)=HisBin(:);
            LocItemVec=LocItemVec+NumItemBlock;
        end 
    end
    vector=HOGVec';
%     toc
return


