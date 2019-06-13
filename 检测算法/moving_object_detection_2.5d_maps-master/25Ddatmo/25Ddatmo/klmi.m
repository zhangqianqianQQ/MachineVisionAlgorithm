%% set kalman parameters
function k = klmi(ocn, ncn, nzn, k, frame, st)
if frame  == st.st.st                                    % all objects in the first frame
k(size(ocn, 2)).s = [];                                  % initialize kalman filter
for      i = 1 : size(ocn, 2)                            % for every detected objects
k(i).s     = kalmani(ocn(:, i));                         % initialize every kalman filter
end
elseif frame ~= st.st.st                                 % not associated objects
n          = size(k, 2);    
for      i = n + 1 : n + size(ncn, 2)                    % for every new objects
k(i).s     = kalmani(ncn(:, i - n));                     % initialize every new kalman filter
k(i).sz    = nzn(:, i - n);
end 
end
end
%% initialize kalman
function s = kalmani(int)
dt         = 0.1;                                        % time step
s.A        = [1 dt 0 0; 0 1 0 0; 0 0 1 dt; 0 0 0 1];     % state transition matrix
s.H        = [1 0 0 0; 0 0 1 0];                         % observation matrix
s.Q        = 5 * eye(4);                                 % process noise covariance
s.R        = [0.5  0; 0 0.5];                            % measurement error covariance
s.x        = [int(1), 0, int(2), 0]';                    % a priori 'state vector' estimate
s.P        = 5 * eye(4);                                 % a priori estimate 'error covariance'
end
