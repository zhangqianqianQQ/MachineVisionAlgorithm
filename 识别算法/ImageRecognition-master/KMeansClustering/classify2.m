function [Y] = classify2(Model, X)    
    [Feat] =  getImages(X);

    M = Model.M;
    [Y] = kmeansClassify(M,Feat);
    Y = Y - 1;
end

function [t] = kmeansClassify(M,Xtest)
    t = zeros(size(Xtest,1),1);
    for i = 1:size(Xtest,1)
        Norms = zeros(10,1);
        for j = 1:10
            Vec = norm(double(M(j,:) - Xtest(i,:)));
            Norms(j) = Vec;
        end
        [~,index] = min(Norms);
        t(i) = index;
    end
end

function [Feat] =  getImages(data)
    Feat = [];
    for i = 1:size(data,1)
        image = reshape(data(i,:),[32,32,3]);
        image = imresize(image,4);
        feat = extract_feature(image);
        Feat = horzcat(Feat,feat);
    end
    Feat = Feat';
end

