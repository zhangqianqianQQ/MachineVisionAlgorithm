%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function dirVert = gradVert(img)
dirVert = zeros(size(img));
dirVert(1:end-1,:,:) = img(2:end,:,:) - img(1:end-1,:,:);
end
