function featuresToUcm(trainSet, paths, imSet)
% featuresToUcm('trainval', getPaths(), 'test')
	for o = 1:8,
		dt = load(fullfile(paths.ucmModels, sprintf('model_o%d-%s.mat', o, trainSet)), 'model_svm');
		model_svm(o) = dt.model_svm;
	end
	imList = getImageSet(imSet);

	parfor i = 1:length(imList),
		imName = imList{i};
		fileName = fullfile(paths.ucmFDir, sprintf('%s.mat', imName));
		dt = load(fileName);
		pb_wt = zeros(size(dt.sPb2, 1), size(dt.sPb2, 2));
		for o=1:8,
			scores_ch  = svm_do_predict(model_svm(o), dt.img_features{o});
			pb_wt(dt.img_ids{o}) = max(pb_wt(dt.img_ids{o}),scores_ch);
		end

		try
			ucm2 = contours2ucm_RGBD(dt.sPb2, pb_wt, dt.thr);
			% Save the ucm somewhere?
			ucmDir = paths.ucmDir;
			fileName = fullfile(paths.ucmDir, strcat(imName, '.mat'));
			parsave(fileName, 'ucm2', ucm2);
		catch
			fprintf('UCM error in image, %s.\n', imName);
		end
	end
end



%%
function scores = svm_do_predict(svm_model, features)
	labels=-ones(size(features,1),1);


	mx2=repmat(svm_model.mx,size(features,1),1);
	mn2=repmat(svm_model.mn,size(features,1),1);
	features = (features-mn2)./((mx2-mn2) + (mx2==mn2));

	features = vl_homkermap(features', svm_model.vlfeat_N, svm_model.KERNEL_TYPE);%0.9.14
	features = sparse(double(features));
	[predicted_label, accuracy, scores] = predict(labels, features, svm_model, '-b 1', 'col');
	id=find(svm_model.Label==1);
	scores = scores(:,id);
end
