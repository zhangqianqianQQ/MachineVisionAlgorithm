function [ Accuracy ] = NBTest()

    %Create HOG Features from the raw image
    %LoadImages()
    %Use either ComputeFeats or BestFeats
    %[Feats] = ComputeFeats();
    [Feats] = BestFeats();
    [Labels] = LoadLabels();

    [P,M,V] = NBTrain(Feats(1:4500,:),Labels(1:4500,:));
    [t] = NBClassify(Feats(4501:5000,:), M', V', P);

    %Change r to size of Train data
    r = 4500;
    C = zeros(10);
    for i = 1:length(t)
        ind1 = t(i);
        ind2 = 1 + Labels(r+i);
        C(ind1,ind2) = C(ind1,ind2) + 1;
    end

    %C is the confusion matrix
    %This shows what the actual value was and what the classified value is
    %Accuracy is measured as the sum of the diagonal elements over all the elements
    Accuracy = trace(C)/sum(sum(C));
end

