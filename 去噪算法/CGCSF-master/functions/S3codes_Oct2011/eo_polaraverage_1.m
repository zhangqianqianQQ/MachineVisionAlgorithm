function [x y] = eo_polaraverage_1(data)

% conversion cartesian to polar and average from 0 [rad] to rr [rad] step
% rr/dr [rad]
% return value excludes average and includes nyquist frequency spectrum
%
% usage:
% s = eo_polaraverage(fftdata)
% [f s] = eo_polaraverage(fftdata)

% $Revision: 1.1 $
% $Date: 2006/08/07 02:57:43 $
% $Author: kannon $

rr = 2*pi; dr = 360;

n = length(data);
% average = data(1,1);
data(1,1) = (data(2,1)+data(1,2))/2;

%for r = 0:(n/2-1)
for r = 1:(n/2) % for each polar frequency 
    zs = 0;
    for ith = 0:(dr-1) % for each 1 degree angle
        th = ith/dr; % convert to radian
        x = r * sin (th*rr); % x coordinate
        y = r * cos (th*rr); % y coordinate

        x1 = sign(x) * floor ( abs (x) ); % rounding
        x2 = sign(x) * ceil  ( abs (x) );
        y1 = sign(y) * floor ( abs (y) );
        y2 = sign(y) * ceil  ( abs (y) );

        ex = abs(x - x1);
        ey = abs(y - y1);
        
        if(x2<0)
            ex = abs(x - x2);
            if(x1<0)
                x1 = n + x1;
            end
            x2 = n + x2;
        end
                
        if(y2<0)
            ey = abs(y - y2);
            if(y1<0)
                y1 = n + y1;
            end
            y2 = n + y2;
        end
        
        f11 = data(x1+1, y1+1);
        f12 = data(x1+1, y2+1);
        f21 = data(x2+1, y1+1);
        f22 = data(x2+1, y2+1);

        %z = interp2([0 1;0 1], [0 0;1 1], [f11 f21;f12 f22], ex, ey, 'linear');
        z = (f21-f11)*ex*(1-ey) + (f12-f11)*(1-ex)*ey + (f22-f11)*ex*ey + f11;

        zs = zs + z;
    end
    s(r+1) = zs/dr;
end

f = linspace(0,0.5,length(s));
s = s(2:end);
f = f(2:end);

if(nargout>=2)
    x = f;
    y = s;
else
    x = s;
end
