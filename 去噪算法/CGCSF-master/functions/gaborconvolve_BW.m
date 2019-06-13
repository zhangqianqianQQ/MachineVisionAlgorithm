function EO = gaborconvolve_BW(im, nscale, norient, minWaveLength, sigmaOnf, mult)
%---------------------------------------------------
% This code gives the logGabor decomposition
% of input image 'im', 'nacale' is the number
% of scale, 'norient' is the number of 
% orientations and 'EO' is the logGabor
% decomposed output. EO is a cell of 
% dimension nscale times norient

% This code has used codes from author: Peter Kovesi   
% Department of Computer Science & Software Engineering
% The University of Western Australia
% pk@cs.uwa.edu.au  www.cs.uwa.edu.au/~pk   
% May 2001
%---------------------------------------------------

[rows cols] = size(im);					

% Author: Peter Kovesi   
% Department of Computer Science & Software Engineering
% The University of Western Australia
% pk@cs.uwa.edu.au  www.cs.uwa.edu.au/~pk   
%
% May 2001


dThetaOnSigma   = 1.5;

   

imagefft = fft2(im);                 % Fourier transform of image
EO = cell(nscale, norient);          % Pre-allocate cell array

% Pre-compute some stuff to speed up filter construction

x = ones(rows,1) * (-cols/2 : (cols/2 - 1))/(cols/2);  
y = (-rows/2 : (rows/2 - 1))' * ones(1,cols)/(rows/2);
radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius from centre.
radius(round(rows/2+1),round(cols/2+1)) = 1; % Get rid of the 0 radius value in the middle 
                                             % so that taking the log of the radius will 
                                             % not cause trouble.

% Precompute sine and cosine of the polar angle of all pixels about the
% centre point					     

theta = atan2(-y,x);              % Matrix values contain polar angle.
                                  % (note -ve y is used to give +ve
                                  % anti-clockwise angles)
sintheta = sin(theta);
costheta = cos(theta);
clear x; clear y; clear theta;      % save a little memory

thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
                                        % angular Gaussian function used to
                                        % construct filters in the freq. plane.
% The low pass filter
lp = fftshift(lowpassfilter([rows,cols],.45,10));   % Radius .4, 'sharpness' 10

% The main loop...

for o = 1:norient,                   % For each orientation.
%   fprintf('Processing orientation %d \n', o);
  angl = (o-1)*pi/norient;           % Calculate filter angle.
  wavelength = minWaveLength;        % Initialize filter wavelength.

  % Pre-compute filter data specific to this orientation
  % For each point in the filter matrix calculate the angular distance from the
  % specified filter orientation.  To overcome the angular wrap-around problem
  % sine difference and cosine difference values are first computed and then
  % the atan2 function is used to determine angular distance.

  ds = sintheta * cos(angl) - costheta * sin(angl);     % Difference in sine.
  dc = costheta * cos(angl) + sintheta * sin(angl);     % Difference in cosine.
  dtheta = abs(atan2(ds,dc));                           % Absolute angular distance.
  spread = exp((-dtheta.^2) / (2 * thetaSigma^2));      % Calculate the angular filter component.

  for s = 1:nscale,                  % For each scale.

    % Construct the filter - first calculate the radial filter component.
    fo = 1.0/wavelength;                  % Centre frequency of filter.
    rfo = fo/0.5;                         % Normalised radius from centre of frequency plane 
                                          % corresponding to fo.
    logGabor = exp((-(log(radius/rfo)).^2) / (2 * log(sigmaOnf)^2));  
    logGabor(round(rows/2+1),round(cols/2+1)) = 0; % Set the value at the center of the filter
                                                   % back to zero (undo the radius fudge).

    filter = fftshift(logGabor .* lp .* spread); % Multiply by the angular spread to get the filter
                                           % and swap quadrants to move zero frequency 
                                           % to the corners.
   
    % Do the convolution, back transform, and save the result in EO
    EO{s,o} = ifft2(imagefft .* filter);    

    wavelength = wavelength * mult;       % Finally calculate Wavelength of next filter
  end                                     % ... and process the next scale
 
end  % For each orientation

end