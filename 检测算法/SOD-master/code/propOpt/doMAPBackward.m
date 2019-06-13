function stat = doMAPBackward(B, S, param, stat)

while ~isempty(stat.O)
    flag = false;
    bestStat = stat;
    for i = 1:numel(stat.O)
        O = stat.O;
        O(i) = [];
        statTmp = doMAPEval(B, S, param, O, stat.W, stat.BGp);
        if statTmp.f > bestStat.f
            flag = true;
            bestStat = statTmp;
        end
    end
    stat = bestStat;
    if ~flag
        break
    end
end