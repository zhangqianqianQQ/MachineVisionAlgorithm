function[proposalsVars] = rpGetProposalsVars(proposalName, newProposalsVars)
% [proposalsVars] = rpGetProposalsVars(proposalName, newProposalsVars)
%
% Define the parameters for a region proposal function.
% Default parameters will be overwritten with those in "newProposalsVars".
%
% Copyright by Holger Caesar, 2015

% Set default arguments
if strcmp(proposalName, 'Felzenszwalb2004'),
    defProposalsVars = {'k', 100, 'sigma', 0.8, 'colorTypes', {'Rgb'}};
elseif strcmp(proposalName, 'Uijlings2013'),
    defProposalsVars = {'ks', 100, 'sigma', 0.8, 'colorTypes', {'Rgb'}};
else
    defProposalsVars = {};
end;

% Copy old proposalsVars
proposalsVars = defProposalsVars;

% Overwrite default arguments if necessary
if ~exist('newProposalsVars', 'var') || isempty(newProposalsVars),
    % Do nothing
else
    % Check number of arguments
    assert(mod(numel(newProposalsVars), 2) == 0);
    
    for attrPairIdx = 1 : numel(newProposalsVars) / 2,
        attrIdx = 1 + (attrPairIdx - 1) * 2;
        matchInds = find(strcmp(defProposalsVars, newProposalsVars{attrIdx}));
        
        if numel(matchInds) == 1,
            % Overwrite existing key
            proposalsVars{matchInds + 1} = newProposalsVars{attrIdx + 1};
        elseif numel(matchInds) == 0,
            % Append new key
            proposalsVars = [proposalsVars, newProposalsVars(attrIdx : attrIdx + 1)]; %#ok<AGROW>
        else
            error('Error: Attributes need to be unique!');
        end;
    end;
end;