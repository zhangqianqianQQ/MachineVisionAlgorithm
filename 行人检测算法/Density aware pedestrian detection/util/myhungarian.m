function [cost,r_id,c_id] = myhungarian(A, c_thresh)

[m,n]   = size(A);
mn  = max(m,n);
B   = c_thresh * ones(mn,mn);
B(1:m,1:n)  = A;

c_id    = 1:n;
C   = mexLap(B);
r_id    = C(1:n);

rc_ind  = sub2ind([mn,mn],r_id,c_id);

cost_a  = B(rc_ind);

valid_match_id  = find(cost_a<c_thresh);

r_id    = r_id(valid_match_id);
c_id    = c_id(valid_match_id);

rc_ind1 = sub2ind([mn,mn],r_id,c_id);
cost    = sum(B(rc_ind1));
