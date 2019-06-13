
function disp_progress(p, p_max)

persistent p_last;
if (nargin == 0)
  p_last = [];  
  fprintf(1, '%s\n', '');
  return;
end

p_done = p / p_max * 100;
p_done = round(p_done / 10) * 10;

%[p_done p_last]

if (p_done == p_last)
  return;
end

if (~isempty(p_last))
%  fprintf(1, '%d\n', p_last);
  fprintf(1, '%s\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b', '');
%  return;
end
p_last = p_done;
  
switch (p_done)
  case 0
    fprintf(1, '%s', '[          ] 0%  ');  
  case 10
    fprintf(1, '%s', '[|         ] 10% ');
  case 20
    fprintf(1, '%s', '[||        ] 20% ');
  case 30
    fprintf(1, '%s', '[|||       ] 30% ');
  case 40
    fprintf(1, '%s', '[||||      ] 40% ');
  case 50
    fprintf(1, '%s', '[|||||     ] 50% ');
  case 60
    fprintf(1, '%s', '[||||||    ] 60% ');
  case 70
    fprintf(1, '%s', '[|||||||   ] 70% ');
  case 80
    fprintf(1, '%s', '[||||||||  ] 80% ');
  case 90
    fprintf(1, '%s', '[||||||||| ] 90% ');
  case 100
    fprintf(1, '%s', '[||||||||||] 100% ');
end
drawnow;

