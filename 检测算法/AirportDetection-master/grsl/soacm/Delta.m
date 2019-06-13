function delta_h = Delta(phi, epsilon)
% Delta(phi, epsilon) compute the smooth Dirac function
    delta_h = (epsilon/pi)./(epsilon^2+ phi.^2);
end