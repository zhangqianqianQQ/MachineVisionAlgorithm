function szg = applySG(zg, radSG)
 	gtheta = [1.5708    1.1781    0.7854    0.3927   0    2.7489    2.3562    1.9635];
 	filters = make_filters(radSG, gtheta);
 	for i = 1:length(zg),
 		if(radSG(i) == 0)
 			szg{i} = zg{i};
 		else
 			for o = 1:8, 
 				szg{i}(:,:,o) = fitparab(abs(zg{i}(:,:,o)),radSG(i),radSG(i)/4,gtheta(o),filters{i,o});
 			end
 		end
 	end
end 
