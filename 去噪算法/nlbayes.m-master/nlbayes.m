% scrip to run two steps of nlbayes

% first step parameters
prms1.wx = 21; % radius of search region
prms1.px =  8; % patch size
prms1.np = 40; % number of sim patches
prms1.r  = -1; % truncated rank of cov matrix (-1 means allow full rank)
prms1.pw = 0;  % use patch window

% second step parameters
prms2.wx = 21; % radius of search region
prms2.px = 4;  % patch size
prms2.np = 20; % number of sim patches
prms2.r  = -1; % truncated rank of cov matrix (-1 means allow full rank)
prms2.pw = 0;  % use patch window

% noise
sigma = 5;

% load image
orig = double(imread('Traffic.png'));
%orig = mean(orig,3);

% crop (matlab implementation is very slow)
cropx = [1,floor(size(orig,2)/4)];
cropy = [1,floor(size(orig,1)/2)];

orig = orig(cropy(1):cropy(2),cropx(1):cropx(2),:);

% add noise
randn('seed',0)
nisy = orig + sigma*randn(size(orig));

[deno1, aggw1] = nlbayes_step(nisy, []   , sigma, prms1);
[deno2, aggw2] = nlbayes_step(nisy, deno1, sigma, prms2);

disp(20*log10(255/sqrt(norm(orig(:) - deno1(:))^2/length(orig(:)))))
disp(20*log10(255/sqrt(norm(orig(:) - deno2(:))^2/length(orig(:)))))

