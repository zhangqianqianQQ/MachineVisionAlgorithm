function VOCopts = get_pedestrian_opts(path)

tmp = pwd;
cd(path);
try
  addpath('VOCcode');
  Pedinit;
catch
  rmpath('VOCcode');
  cd(tmp);
  error(sprintf('VOCcode directory not found under %s', path));
end
rmpath('VOCcode');
cd(tmp)