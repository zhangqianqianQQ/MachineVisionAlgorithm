function boundingbox = visualizeSet(image,labels,set)
scorelabels = labels;
for i = 1:length(set)
    for j = 2:length(set)
        scorelabels(scorelabels == set(1,j)) = set(1,1);
    end
end

scorelabels(scorelabels ~= set(1,1)) = 0;
scorelabels(scorelabels ~= 0) = 1;

st = regionprops(scorelabels, 'BoundingBox' );
boundingbox = st.BoundingBox;

figure;
imshowpair(image, label2rgb(scorelabels), 'montage');

end

