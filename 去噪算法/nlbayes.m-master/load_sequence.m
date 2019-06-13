function v = load_sequence(inpat, from, to)

% load first frame to get dimensions, channels
im = single(imread(sprintf(inpat,from)));
sz = [size(im,1) size(im,2)];
ch =  size(im,3);
nf = to - from + 1;

% allocate video volume
v = single(zeros(sz(1), sz(2), ch, nf));

% load sequence 
disp(sprintf('Reading %s', inpat))
for i = [from:to],

	filename = sprintf(inpat,i);
%	disp(sprintf('Reading %s', filename))
	im = single(imread(filename));
	v(:,:,:,i - from + 1) = im;

end
