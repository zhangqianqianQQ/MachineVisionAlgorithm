function[res] = varargToStr(separator, varargin)
% [res] = varargToStr([separator], varargin)
%
% Convert a cell of sth. to a single str.
% Output is similar to evalc('disp(proposalsVars)'), but without spaces and
% fancy characters.
%
% Copyright by Holger Caesar, 2015

res = '';
if ~exist('separator', 'var') || isempty(separator),
    separator = '';
end;

for i = 1 : numel(varargin),
    cur = varargin{i};
    
    if ischar(cur),
        % Do nothing
    elseif isnumeric(cur),
        cur = num2str(cur);
    elseif iscell(cur),
        cur = varargToStr(separator, cur{:});
    elseif isfunc(cur),
        cur = func2str(cur);
    else
        error('Error: Invalid type!');
    end;
    
    % Concatenate result
    if mod(i, 2) == 1 && i > 1,
        res = [res, separator, cur];
    else
        res = [res, cur];
    end;
end;