function h = sfigure(varargin)
% SFIGURE  Create figure window (minus annoying focus-theft).
%
% Usage is identical to figure.
%
% Daniel Eaton, 2005
% Anton Guimerà Brunet, 2011
%% See also "help figure"

if nargin>=1
	h = varargin{1};
	if ishandle(h)
    	set(0, 'CurrentFigure', h);
    else
        par = '';
        for i=1:nargin
            var = sprintf ('var%d',i);
            par = sprintf ('%s,%s',par,var);
            eval (sprintf('%s = varargin{%d};',var,i));
        end
        par = par (2:length(par));
        eval (sprintf('h = figure(%s);',par));
	end
else
    par = '';
    for i=1:nargin
        var = sprintf ('var%d',i);
        par = sprintf ('%s,%s',par,var);
        eval (sprintf('%s = varargin{%d};',var,i));
    end
    par = par (2:length(par));
    eval (sprintf('h = figure(%s);',par));
end




