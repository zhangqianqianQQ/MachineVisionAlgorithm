%% data association for every kalman filter (every object from previous frame)
function [k, ocn, szn] = asc(k, ocn, szn)
for i             = 1 : size(k, 2)                      % for every kalman filter
[k(i).s, idx]     = assoc(k(i).s, ocn);                 % apply data association
k(i).sz           = szn(:, idx);
szn(:, idx)       = [];
ocn(:, idx)       = [];                                 % eliminated checked objects from the new frame and go for
end                                                     % associating remained objects to the next kalman filter
end
%% data association: 1. no object, 2. one object, 3. multiple objects
function [s, idx] = assoc(s, ocn)
can    = ocn(1 : 2, :);                                 % candidates                                               
pe     = [s.x(1); s.x(3)];                              % previous estimate (to do: replace with last prediction!)
gate   = 4;                                             % gating: 7 
idx    = ((sum((can - repmat(pe, 1, size(can, 2)))...   % indexes of objects inside the gate
         .^2)) .^0.5) < gate;
if     sum(idx) == 0                                    % 1. no object
s.z    = pe;                                            % previous estimate/prediction!
elseif sum(idx) == 1                                    % 2. one object
s.z    = can(:, idx);                                   % associated object
elseif sum(idx) > 1                                     % 3. multiple objects (take nearest object)
idx    = ((sum((can - repmat(pe, 1, size(can, 2)))...   % index of the nearest object
         .^2)) .^0.5) == min((sum((can - repmat(pe...
         , 1, size(can, 2))) .^2)) .^0.5);
s.z    = can(:, idx);                                   % associated object
end
end
