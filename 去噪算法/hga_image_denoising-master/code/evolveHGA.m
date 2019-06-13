%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function pop = evolveHGA(population, sizePop, localSearchRate, beta, lambda, noisyImage, maxTime, numIter, tournSize)

bestID = population(1).id;

cont = 0;

t = tic;

while (toc(t) < maxTime && cont < numIter)
    
    population = evolve(population, sizePop, localSearchRate, beta, lambda, noisyImage, tournSize);
    population = arrangePop(population);  
    population = population(1:sizePop);
    
    if(strcmp(population(1).id, bestID))
        cont = cont + 1;
    else
        cont = 0;
        bestID = population(1).id;
    end
        
end

population = arrangePop(population);
pop = population;

end

function pop = evolve(population, tamPop, localSearchRate, beta, lambda, noisyImg, tournSize)

for i=1:tamPop

    [p1, p2] = selectParents(tamPop, tournSize);

    filho = crossover(population(p1).cromo,population(p2).cromo);

    if(rand < localSearchRate)
        filho = localSearch(filho);
    end

    fit = calcFitness(filho, noisyImg, beta, lambda);
    population(tamPop + i).cromo = filho;
    population(tamPop + i).fitness = fit;
    population(tamPop + i).id = char(java.util.UUID.randomUUID.toString);
end

pop = population;

end

function [p1, p2] = selectParents(sizePop, sizeTournament)

parents = [];

while(length(parents) < sizeTournament)
    
    tmp = randi([1,sizePop]);
    
    if(~ismember(tmp, parents))
        parents = [parents, tmp];
    end
    
end

p1 = min(parents);

parents = [];

while(length(parents) < sizeTournament)
    
    tmp = randi([1,sizePop]);
    
    if(~ismember(tmp, parents) && tmp ~= p1)
        parents = [parents, tmp];
    end
    
end

p2 = min(parents);

end
