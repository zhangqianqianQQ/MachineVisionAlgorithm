function w=MLRTrainL1(data,label,lambda,max_iter_num)
[N,D]=size(data);
M=length(unique(label));
Y=zeros(M,N);
for nn=1:N
    Y(label(nn),nn)=1;
end
Y=Y(1:end-1,:);
w=ones(D*(M-1),1);
% Compute B Matrix
Temp=0;
for nn=1:N
    Temp=Temp+data(nn,:)'*data(nn,:);
end
Temp1=-(eye(M-1)-ones(M-1,M-1)/M)/2;
B=kron(Temp1,Temp);

% Update w
for tau=1:max_iter_num
    g=0;
    for nn=1:N
        pp=zeros(M-1,1);
        for mm=1:M-1
            wtmp=w((mm-1)*D+1:mm*D);
            pp(mm)=exp(data(nn,:)*wtmp);
        end
        pp=pp/(1+sum(pp));
        temp=Y(:,nn)-pp;
        g=g+kron(temp,data(nn,:)');
    end
    %     w=w-B\g;
    BB=B-lambda*diag(1./(abs(w)+1));
    BBB=BB\B;
    w=BBB*w-BB\g;
end

w=reshape(w,[D M-1]);
w=[w,zeros(D,1)];


