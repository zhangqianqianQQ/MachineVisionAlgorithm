% Build parameters array of given ellipses
function [X, Y, A, B, Alpha] = splitParameters(Ellipses)

numEllipses = length(Ellipses);
X = zeros(numEllipses,1);
Y = zeros(numEllipses,1);
A = zeros(numEllipses,1);
B = zeros(numEllipses,1);
Alpha = zeros(numEllipses,1);

for i = 1:numEllipses
    X(i) = Ellipses{i}.Z(2);
    Y(i) = Ellipses{i}.Z(1);
    A(i) = Ellipses{i}.A;
    B(i) = Ellipses{i}.B;
    Alpha(i) = Ellipses{i}.Alpha;
   
end

end
