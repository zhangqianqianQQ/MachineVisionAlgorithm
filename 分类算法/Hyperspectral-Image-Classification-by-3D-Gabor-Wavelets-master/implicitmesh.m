function h = implicitmesh(f,xlimit,ylimit,zlimit,gd)
%implicitmesh(f,span,gd):画隐函数曲面f(x,y,z)=0的网格图,
%gd为取样点数，默认为25点
if nargin==2
    ylimit=xlimit;zlimit=xlimit;gd=25;
elseif nargin==3
    gd=ylimit;ylimit=xlimit;zlimit=xlimit;
elseif nargin==4
    gd=25;
elseif nargin==5
else
    error('Error in input arguments')
end
x=linspace(xlimit(1),xlimit(2),gd);
y=linspace(ylimit(1),ylimit(2),gd);
z=linspace(zlimit(1),zlimit(2),gd);
[x,y,z]=meshgrid(x,y,z);val=f(x,y,z);
[f,v]=isosurface(x,y,z,val,0);
if isempty(f)
    warning('There is no graph in the range.');
    p=[];
else
    newplot;
    p=patch('Faces',f,'Vertices',v,'CData',v(:,3),'facecolor','w','EdgeColor','flat');
    isonormals(x,y,z,val,p);
    view(3);
    grid on
end
if nargout==0
else
    h=p;
end

end

