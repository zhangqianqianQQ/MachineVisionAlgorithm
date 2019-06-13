function evalRes = wrapperScene(typ, trSet, valSet, testSet, classMapping, sceneMapping, objectDir)
	paths = getPaths();
	
	modelFileName = trainSceneModel({trSet, valSet}, paths, typ, classMapping, sceneMapping, objectDir);
	outputFileName = testSceneModel(testSet, paths, modelFileName);
	evalRes = benchmarkScene(outputFileName, sceneMapping, testSet);
end
