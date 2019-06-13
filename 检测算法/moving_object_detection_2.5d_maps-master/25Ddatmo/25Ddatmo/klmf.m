%% kalman tracking
function k = klmf(k)
for i      = 1 : size(k, 2)                         % for every kalman filter
k(i).s     = kalmanf(k(i).s);                       % update kalman filter 
end
end
%% update kalman
function s = kalmanf(s)
s.x        = s.A * s.x;                             % prediction for state vector and covariance
s.P        = s.A * s.P * s.A' + s.Q;                % covariance of the state vector estimate
K          = s.P * s.H' / (s.H * s.P * s.H' + s.R); % compute Kalman gain factor
s.x        = s.x + K * (s.z - s.H * s.x);           % correction based on observation
s.P        = s.P - K * s.H * s.P;
end