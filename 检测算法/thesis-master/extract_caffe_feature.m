function features = extract_caffe_feature(patch, caffe_params)
    
    def_file = ['models/' caffe_params.model '/' caffe_params.def_file];
    model_file = ['models/' caffe_params.model '/' caffe_params.model_file];

    if caffe('is_initialized') == 0
        caffe('init', def_file, model_file);
        caffe('set_phase_test');
        caffe('set_device', caffe_params.device);
        caffe('set_mode_gpu');
    end
    
    images = {prepare_image(patch, caffe_params.oversample)};
    features = caffe('forward', images);
    features = permute(features{1}, [3 4 1 2]);
end