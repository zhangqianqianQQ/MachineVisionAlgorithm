function [sub,fls] = subdir(CurrPath)
%   SUBDIR  lists (recursive) all subfolders and files under given folder
%    
%   SUBDIR
%        returns all subfolder under current path.
%
%   P = SUBDIR('directory_name') 
%       stores all subfolders under given directory into a variable 'P'
%
%   [P F] = SUBDIR('directory_name')
%       stores all subfolders under given directory into a
%       variable 'P' and all filenames into a variable 'F'.
%       use sort([F{:}]) to get sorted list of all filenames.
%
%   See also DIR, CD

%   author:  Elmar Tarajan [Elmar.Tarajan@Mathworks.de]
%   version: 2.0 
%   date:    07-Dez-2004
%
if nargin == 0
   CurrPath = cd;
end% if
if nargout == 1
   sub = subfolder(CurrPath,'');
else
   [sub fls] = subfolder(CurrPath,'','');
end% if
  %
  %
function [sub,fls] = subfolder(CurrPath,sub,fls)
%------------------------------------------------
tmp = dir(CurrPath);
tmp = tmp(~ismember({tmp.name},{'.' '..'}));
for i = {tmp([tmp.isdir]).name}
   sub{end+1} = [CurrPath '\' i{:}];
   if nargin==2
      sub = subfolder(sub{end},sub);
   else
      tmp = dir(sub{end});
      fls{end+1} = {tmp(~[tmp.isdir]).name};
      [sub fls] = subfolder(sub{end},sub,fls);
   end% if
end% if