%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function pop = restartPop(pop, sizePop, denoisedImages, img, beta, lambda)

popTemp(sizePop).fitness = 0;
popTemp(sizePop).cromo = [];
popTemp(sizePop).id = '';
popTemp(1) = pop(1);

mut1 = denoisedImages(1).img;
mut2 = denoisedImages(2).img;
mut3 = denoisedImages(3).img;

fit1 = calcFitness(mut1, img, beta, lambda);
fit2 = calcFitness(mut2, img, beta, lambda);
fit3 = calcFitness(mut3, img, beta, lambda);

popTemp(2).fitness = fit1;
popTemp(2).cromo = mut1;
popTemp(2).id = char(java.util.UUID.randomUUID.toString);

popTemp(3).fitness = fit2;
popTemp(3).cromo = mut2;
popTemp(3).id = char(java.util.UUID.randomUUID.toString);

popTemp(4).fitness = fit3;
popTemp(4).cromo = mut3;
popTemp(4).id = char(java.util.UUID.randomUUID.toString);

for i = 5:sizePop
    tmp = denoisedImages(randi(3)).img;
    popTemp(i).cromo = mutation(tmp);    
    popTemp(i).fitness = calcFitness(popTemp(i).cromo, img, beta, lambda);
    popTemp(i).id = char(java.util.UUID.randomUUID.toString);
end

pop = arrangePop(popTemp);

end

