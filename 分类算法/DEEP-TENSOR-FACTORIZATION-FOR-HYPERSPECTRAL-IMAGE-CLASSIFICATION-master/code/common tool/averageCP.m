function [ deepOA,deepAA,deepOAPerclass,deepKappa,comOA,comAA,comOAPerclass,comKappa ] = averageCP( loadPath,stringOfDataset,stringOfRatio )
%计算5次分解结果的平均值

deepOA = zeros(4,3);
deepOAPerclass = cell(4,3);
deepAA = zeros(4,3);
deepKappa = zeros(4,3);

comOA = zeros(1,4);
comOAPerclass = cell(1,4);
comAA = zeros(1,4);
comKappa = zeros(1,4);

for iter= 0:4
    path = sprintf('%s\\%s_%s_SVMLinear%d.mat',loadPath,stringOfDataset,stringOfRatio,iter);
    load(path);
    % 计算三层的OA
    name = sprintf('%s_%s_SVMLinear_OAPredict',stringOfDataset,stringOfRatio);
    for layer = 1:3
        for times = 1:4
            eval(['tempOA(times,layer) = average(',name,'{layer,times})']);
        end
    end
    deepOA = deepOA + tempOA;
    % 计算三层AA
    name = sprintf('%s_%s_SVMLinear_AAPredict',stringOfDataset,stringOfRatio);
    for layer = 1:3
        for times = 1:4
            eval(['tempAA(times,layer) = average(',name,'{layer,times})']);
        end
    end
    deepAA = deepAA + tempAA;
    % 计算三层OAPerclass
    name = sprintf('%s_%s_SVMLinear_OAPerclass',stringOfDataset,stringOfRatio);
    for layer = 1:3
        for times = 1:4
            eval(['tempOAPerclass{times,layer} = averagePerclass(',name,'{layer,times})']);
        end
    end
    for layer = 1:3
        for times = 1:4
            if iter == 0
                deepOAPerclass{times,layer} = zeros(size(tempOAPerclass{times,layer}));
            end
            deepOAPerclass{times,layer} = deepOAPerclass{times,layer} + tempOAPerclass{times,layer};
        end
    end
    % 计算三层Kappa
    name = sprintf('%s_%s_SVMLinear_Kappa',stringOfDataset,stringOfRatio);
    for layer = 1:3
        for times = 1:4
            eval(['tempKappa(times,layer) = average(',name,'{layer,times})']);
        end
    end
    deepKappa = deepKappa + tempKappa;
    % 计算三层合并的OA
    name = sprintf('%s_%s_SVMLinear_Combin_OAPredict',stringOfDataset,stringOfRatio);
    for times = 1:4
        eval(['tempComOA(times) = average(',name,'{times})']);
    end
    comOA = comOA + tempComOA;
    % 计算三层合并的OAPerclass
    name = sprintf('%s_%s_SVMLinear_Combin_OAPerclass',stringOfDataset,stringOfRatio);
    for times = 1:4
        eval(['tempComOAPerclass{times} = averagePerclass(',name,'{times})']);
    end
    for times = 1:4
        if iter == 0
            comOAPerclass{times} = zeros(size(tempComOAPerclass{times}));
        end
        comOAPerclass{times} = comOAPerclass{times} + tempComOAPerclass{times};
    end
    % 计算三层合并的Kappa
    name = sprintf('%s_%s_SVMLinear_Combin_Kappa',stringOfDataset,stringOfRatio);
    for times = 1:4
        eval(['tempComKappa(times) = average(',name,'{times})']);
    end
    comKappa = comKappa + tempComKappa;
    % 计算三层合并的AA 
    name = sprintf('%s_%s_SVMLinear_Combin_AAPredict',stringOfDataset,stringOfRatio);
    for times = 1:4
        eval(['tempComAA(times) = average(',name,'{times})']);
    end
    comAA = comAA + tempComAA;
end

deepOA = deepOA ./ 5;
deepAA = deepAA ./ 5;
for layer = 1:3
    for times = 1:4
        deepOAPerclass{times,layer} = deepOAPerclass{times,layer} ./ 5;
    end
end
deepKappa = deepKappa ./ 5;

comOA = comOA ./ 5;
comAA = comAA ./ 5;
for times = 1:4
    comOAPerclass{times} = comOAPerclass{times} ./ 5;
end
comKappa = comKappa ./ 5;