%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function f = calcFitness(img, noisyImg, beta, lambda)
beta2 = beta.^2;
I_x = gradHorz( img );
I_y = gradVert( img );
N = sqrt(1 + beta2*( I_x.^2 + I_y.^2 ));
f = sum(N(:) + lambda/2*(double(img(:))-double(noisyImg(:))).^2);
end