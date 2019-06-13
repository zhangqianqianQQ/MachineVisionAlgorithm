function [] = showShp(Plocexp,polygon,column,relative)

ny = size(Plocexp,1);
nx = size(Plocexp,2);
nb_nodes = size(Plocexp,3);

polygonExp = polygon;
for x=1:ny
    for y=1:nx
        for i=1:size(Plocexp,3)
            temp2(i) = round(Plocexp(x,y,i),2);
        end
        temp3 = num2cell(temp2);
        columnName = strcat('C', strcat( num2str(x) ,strcat( 'x' , num2str(y) )  ) );
        [polygonExp.(columnName)] = temp3{:};
    end
end

colormap(summer(512))
if(relative == true)
    a = min([polygonExp.(column)]);
    b = max([polygonExp.(column)]);    
else
    a = 0;
    b = 1;

end

faceColors = makesymbolspec('Polygon', ...
        {char(column),[a b],'FaceColor',colormap});
geoshow(polygonExp,'SymbolSpec',faceColors)
colorbar
caxis([a b])
end
