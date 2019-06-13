function[variables] = replaceVariables(obj, variables)
% [variables] = replaceVariables(obj, variables)
%
% Replace all default variables (x\d+) with free variables.
%
% Copyright by Holger Caesar, 2015

for i = 1 : numel(variables),
    oldVariable = variables{i};
    
    if regexp(oldVariable, 'x\d+'),
        freeVariable = getFreeVariable(obj);
        variables{i} = freeVariable;
    end;
end;