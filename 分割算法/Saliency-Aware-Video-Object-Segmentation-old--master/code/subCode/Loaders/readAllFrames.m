function  [frames, names, height,width,nframe ] = readAllFrames(options)

    frameFiles = imdir(fullfile(options.infolder));
    nframe = length( frameFiles);
    frames = cell( nframe, 1 );
    names = cell( nframe, 1 );
    for index = 1: nframe 
        [~, frameName] = fileparts(frameFiles(index).name);
        if exist(fullfile(options.infolder, [frameName '.png']),'file')
            frame = imread(fullfile(options.infolder, [frameName '.png']));
        elseif exist(fullfile(options.infolder, [frameName '.jpg']),'file')
            frame = imread(fullfile(options.infolder, [frameName '.jpg']));
        elseif exist(fullfile(options.infolder, [frameName '.bmp']),'file')
            frame = imread(fullfile(options.infolder, [frameName '.bmp']));
        end
        frames{ index } = double(frame);
        names{ index } =  frameName;
    end
    [ height,width ] = size(frame(:,:,1));
end
