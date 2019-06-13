%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

Executes the HGA and returns the best image found.

Parameters:

- sizePop: Size of the Population
- noisyImage: The noisy image (matrix of uint8)
- localSearchRate: Local search rate
- maxTime: Time spent on the execution
- numIter: Max number of iterations without improving the best individual
without before restarting the population
- beta: Beta value
- tournSize: Tournament size


%}

function [f, bestAG] = execHGA(sizePop, noisyImage, localSearchRate, maxTime, numIter, beta, tournSize)

lambda = 1/sqrt(estimateVariance(noisyImage));

denoisedImages(3).img = [];

denoisedImages(1).img = uint8(wavewiener2(noisyImage, 'db3', 4));
denoisedImages(2).img = uint8(lpa(noisyImage));
[~, tmp] = BM3D(1,noisyImage);
denoisedImages(3).img = uint8(tmp*255);

pop = createPop(sizePop, noisyImage, denoisedImages, beta, lambda);

s = tic;

while(toc(s) < maxTime)
    
    pop = evolveHGA(pop, sizePop, localSearchRate, beta, lambda, noisyImage, maxTime, numIter, tournSize);   
    if(toc(s) < maxTime)
        pop = restartPop(pop,sizePop,denoisedImages, noisyImage, beta, lambda);
    end
    
end

bestAG = pop(1).cromo;

f = bestAG;

end
