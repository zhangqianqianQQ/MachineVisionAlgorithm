%% Run a demo of a single execution of the HGA

sizePop = 15;
noisyImage = imread('..\noisy_images\glasses.png_30_noisy.png');
localSearchRate = 0.6;
maxTime = 300;
numIter = 5;
beta = 1.5;
tournSize = 3;

fprintf('Starting execution.\n');

f = execHGA(sizePop, noisyImage, localSearchRate, maxTime, numIter, beta, tournSize);

imshow(f);

fprintf('Execution ended.\n');