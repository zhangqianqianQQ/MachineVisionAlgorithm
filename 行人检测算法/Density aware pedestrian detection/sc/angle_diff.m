function d = angle_diff(v1, v2);

sc1 = cos(v1);
sc2 = cos(v2);
ss1 = sin(v1);
ss2 = sin(v2);

d = atan2(ss1.*sc2-ss2.*sc1, sc1.*sc2+ss1.*ss2);
