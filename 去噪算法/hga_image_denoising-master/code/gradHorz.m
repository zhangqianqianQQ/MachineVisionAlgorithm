%{
Authors:
Jonatas Lopes de Paiva
Claudio Fabiano Motta Toledo
Helio Pedrini

%}

function dirHorz = gradHorz(img)
dirHorz = zeros(size(img));
dirHorz(:,1:end-1,:) = img(:,2:end,:) - img(:,1:end-1,:);
end

