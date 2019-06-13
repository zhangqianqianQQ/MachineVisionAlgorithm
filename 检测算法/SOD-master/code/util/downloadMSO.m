
fprintf('downloading the MSO dataset\n');
if ~exist('dataset/MSO','dir')
    mkdir('dataset/MSO');
end
urlwrite('http://www.cs.bu.edu/groups/ivc/data/SOS/MSO.zip', 'dataset/MSO.zip');
fprintf('extracting the zip file\n');
unzip('dataset/MSO.zip', 'dataset/MSO/')