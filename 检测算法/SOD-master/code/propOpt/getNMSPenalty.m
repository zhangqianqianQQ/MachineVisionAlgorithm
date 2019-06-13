function p = getNMSPenalty(B,b)

p = -0.5*(getMaxIncFloat(B',b)+getIOUFloat(B',b));