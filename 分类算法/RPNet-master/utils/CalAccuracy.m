function [OA Kappa producerA] = CalAccuracy(predict_label,label)

n = size(label,1);
OA = sum(predict_label==label)/size(label,1);

for i=1:max(label(:))
    correct_sum(i) = sum(label(find(predict_label==i))==i);
    reali(i) = sum(label==i);
    predicti(i) = sum(predict_label==i);
    producerA(i) = correct_sum(i) / reali(i);
end

Kappa = (n*sum(correct_sum) - sum(reali .* predicti)) / (n*n - sum(reali .* predicti));

end
