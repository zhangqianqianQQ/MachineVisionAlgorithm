function VOCopts = get_voc_opts(path,imageset)

tmp = pwd;
cd(path);
try
  addpath('VOCcode');
  clear VOCopts
  VOCopts = VOCinit(imageset);
catch
  rmpath('VOCcode');
  cd(tmp);
  error(sprintf('VOCcode directory not found under %s', path));
end
rmpath('VOCcode');
cd(tmp);
