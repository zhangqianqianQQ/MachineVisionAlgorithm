%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function pop = createPop(sizePop, img, denoisedImages, beta, lambda  )

population(sizePop).fitness = 0;
population(sizePop).cromo = [];
population(sizePop).id = '';

mut1 = denoisedImages(1).img;
mut2 = denoisedImages(2).img;
mut3 = denoisedImages(3).img;

fit1 = calcFitness(mut1, img, beta, lambda);
fit2 = calcFitness(mut2, img, beta, lambda);
fit3 = calcFitness(mut3, img, beta, lambda);

population(1).fitness = fit1;
population(1).cromo = mut1;
population(1).id = char(java.util.UUID.randomUUID.toString);

population(2).fitness = fit2;
population(2).cromo = mut2;
population(2).id = char(java.util.UUID.randomUUID.toString);

population(3).fitness = fit3;
population(3).cromo = mut3;
population(3).id = char(java.util.UUID.randomUUID.toString);

for i = 4:sizePop
    tmp = denoisedImages(randi(3)).img;
    population(i).cromo = mutation(tmp);
    population(i).fitness = calcFitness(population(i).cromo, img, beta, lambda);
    population(i).id = char(java.util.UUID.randomUUID.toString);
end

pop = arrangePop(population);

end

