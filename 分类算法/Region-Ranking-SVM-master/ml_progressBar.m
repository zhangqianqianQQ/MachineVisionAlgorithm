function ml_progressBar(k,n, prefixMessage, startT)
% n: total
% k: current progress
% By: Minh Hoai Nguyen (minhhoai@robots.ox.ac.uk)
% Created: 24-Mar-2013
% Last modified: 24-Mar-2013

if ~exist('prefixMessage', 'var') || isempty(prefixMessage)
    prefixMessage = 'Progress';
end;

nDigit = length(sprintf('%d',n));

if exist('startT', 'var') && ~isempty(startT)
    format = sprintf('%%%dd/%d (%%6.2f%%%%), elapse time: %7.1fs', nDigit, n, toc(startT));
    delFormat = repmat('\b', 1, 2*nDigit+11+23);    
else
    format = sprintf('%%%dd/%d (%%6.2f%%%%)', nDigit, n);
    delFormat = repmat('\b', 1, 2*nDigit+11);
end
if k==1
    fprintf('\n');
    fprintf([prefixMessage ' ' format], k, 100*k/n);
elseif k == n
    fprintf([delFormat, format, '\n'], k, 100*k/n);
    %fprintf(['\n', prefixMessage ' ' format], k, 100);
else
    fprintf([delFormat, format], k, 100*k/n);
end;


% This function is from Yusuf
% if (k==1)
%     fprintf('\nProgress %05.2f %%',100*k/n);
% elseif (k==n)
%     fprintf('\b\b\b\b\b\b\b\b %05.2f %%\n',100*k/n);
% else    
%     fprintf('\b\b\b\b\b\b\b\b %05.2f %%',100*k/n);
% end
% 
% end