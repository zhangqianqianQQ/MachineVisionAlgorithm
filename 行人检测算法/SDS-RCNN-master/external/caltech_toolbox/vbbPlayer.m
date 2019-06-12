function vbbPlayer( s, v )
% Simple GUI to play annotated videos (seq files)
%
% Uses the seqPlayer to display a video (seq file). See help for the
% seqPlayer for navigation options (playing forward/backward at variable
% speeds). Note that loading a new video via the file menu will not work
% (as the associated annotation is not loaded). The location of the videos
% and associated annotations (vbb files) are specified using dbInfo. To
% actually alter the annotations, use the vbbLabeler.
%
% USAGE
%  vbbPlayer( [s], [v] )
%
% INPUTS
%  s      - set index (randomly generated if not specified)
%  v      - vid index (randomly generated if not specified)
%
% OUTPUTS
%
% EXAMPLE
%  vbbPlayer
%
% See also SEQPLAYER, DBINFO, VBB, VBBLABELER, DBBROWSER
%
% Caltech Pedestrian Dataset     Version 3.2.1
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

[pth,setIds,vidIds] = dbInfo;

if(nargin<1 ||isempty(s)), s=randint2(1,1,[1 length(setIds)]); end
if(nargin<2 ||isempty(v)), v=randint2(1,1,[1 length(vidIds{s})]); end
assert(s>0 && s<=length(setIds)); assert(v>0 && v<=length(vidIds{s}));

vStr = sprintf('set%02i/V%03i',setIds(s),vidIds{s}(v));
fprintf('displaying vbb for %s\n',vStr);
A = vbb('vbbLoad', [pth '/annotations/' vStr] );
vbb( 'vbbPlayer', A, [pth '/videos/' vStr] );

end
