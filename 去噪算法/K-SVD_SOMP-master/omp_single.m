function [a,indx]=omp_single(D,x,errorGoal)
     

	 indx = [];
	 a = [];
     j = 0;
     
      n=length(x);
      maxNumCoef=n/2;
      E2=n*(errorGoal^2);
      
     residual=x;
	 currResNorm2 = sum(residual.^2);
	
    
    while currResNorm2>E2 && j < maxNumCoef,
		j = j+1;
        %找出残差在字典的哪个列上的系数最大
        proj=D'*residual;
        pos=find(abs(proj)==max(abs(proj)));
        pos=pos(1);
        %将这列添加进用来表示x的字中
        indx(j)=pos;
        
        %求出用这些字表示x的系数和残差
        a=pinv(D(:,indx(1:j)))*x;
        residual=x-D(:,indx(1:j))*a;
		currResNorm2 = sum(residual.^2);
    end
 
    
    %返回字典中用来表示x的列们的列标和对应的系数
end