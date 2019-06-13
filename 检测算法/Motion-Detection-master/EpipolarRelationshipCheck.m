function [d] = EpipolarRelationshipCheck(p1,p2,F)

pp2 = p2;
ph2 = e2h(pp2);
l = F'*ph2;
l = l/sqrt(l(1)^2+l(2)^2);

pp1 = p1;
ph1 = e2h(pp1);

d = ph1'*l;