function y = isodifstep(x, d)
% ISODIFSTEP   Isotropic diffusion step
%
%    y = ISODIFSTEP(x, d) calculates de isotropic (scalar) diffusion
%    step "y" based on the image "x" and on the diffusivity "d". If
%    "d" is constant the diffusion will be linear, if "d" is
%    a matrix the same size as "x" the diffusion will be nonlinear.
%
%    The diffused image is calculated as:
%      xd = x + T*isodifstep(x,d)  , T = step size
%

% Translations of d
%d_dop = roll(d,[0 1]);
%d_dom = roll(d,[0 -1]);
%d_dpo = roll(d,[1 0]);
%d_dmo = roll(d,[-1 0]);

%Hace promediado en dirección-----
d_dpo = d + roll(d,[1  0]);
d_dmo = roll(d_dpo,[-1 0]);
d_dop = d + roll(d,[0  1]);
d_dom = roll(d_dop,[0 -1]);

% Translations of x
%xop = roll(x,[0 1]);
%xom = roll(x,[0 -1]);
%xpo = roll(x,[1 0]);
%xmo = roll(x,[-1 0]);

x_xpo = x - roll(x,[1  0]);
x_xmo = roll(x_xpo,[-1 0]); % Must multiply -1
x_xop = x - roll(x,[0  1]);
x_xom = roll(x_xop,[0 -1]); % Must multiply -1

% Calculate y = dx/dt
%y = -.5 * ( (d+dmo).*(x-xmo) + (dpo+d).*(x-xpo) + (d+dom).*(x-xom) + (dop+d).*(x-xop)  );

y =   .5 * ( (d_dmo).*(x_xmo) - (d_dpo).*(x_xpo) + (d_dom).*(x_xom) - (d_dop).*(x_xop)  );

%y = (d_dmo).*(x_xmo) - (d_dpo).*(x_xpo) + (d_dom).*(x_xom) - (d_dop).*(x_xop)  ;