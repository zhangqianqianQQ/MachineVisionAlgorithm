function [AC, nmi_value, error_cnt] = CalcMetrics(label, result)

result = bestMap(label, result);
error_cnt = sum(label ~= result);
AC = length(find(label == result))/length(label);

nmi_value = nmi(label, result);

