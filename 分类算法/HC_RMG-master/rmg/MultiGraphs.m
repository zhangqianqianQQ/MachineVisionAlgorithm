

%construct multi-graphs
%kg---number of graphs
%kf---number of features used by every graph

function [G,F]=MultiGraphs(X,labels,label_index,kg,kf)

  n=size(X,1);
  k=length(unique(labels));
  G=cell(kg,1);
  F=zeros(n,k);
  parfor i=1:kg
      fprintf('... ... the %dth graph computation ... ...\n', i);
      X1=SelectFeatures(X, kf, i);
      
      % gaofeng revised code
      % 修改为和训练样本一样多
      % m=floor(n*0.1);
      m = length(label_index);
      A=Anchors(X1,m);
      A=[A;X1(label_index,:)];
      s = 3;
      cn = 10;
      [Z,rL] = AnchorGraph(X1', A', s, 0, cn); % 1代表使用LAE求解Z
      
      F1 = AnchorGraphReg(Z, rL, labels', label_index, 0.01);
      
      G{i}=F1;
      F=F+F1;
  end
  F=F/kg;
end



