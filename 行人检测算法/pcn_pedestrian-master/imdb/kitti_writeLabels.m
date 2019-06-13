function kitti_writeLabels(boxes,label_dir,img_idx)

mkdir_if_missing(label_dir);
% parse input file
fid = fopen(sprintf('%s/%s.txt',label_dir,img_idx),'w');

% for all objects do
for o = 1:size(boxes,1)

  % set label, truncation, occlusion
  if 1,   fprintf(fid,'Pedestrian '); end

  if 0,   fprintf(fid,'%.2f ',boxes(o).truncation);
  else                                   fprintf(fid,'-1 '); end; % default
  if 0,    fprintf(fid,'%.d ',boxes(o).occlusion);
  else                                   fprintf(fid,'-1 '); end; % default
  if 0,        fprintf(fid,'%.2f ',wrapToPi(boxes(o).alpha));
  else                                   fprintf(fid,'-10 '); end; % default

  % set 2D bounding box in 0-based C++ coordinates
  if 1,           fprintf(fid,'%.2f ',boxes(o,1));
  else                                   error('ERROR: x1 not specified!'); end;
  if 1,           fprintf(fid,'%.2f ',boxes(o,2));
  else                                   error('ERROR: y1 not specified!'); end;
  if 1,           fprintf(fid,'%.2f ',boxes(o,3));
  else                                   error('ERROR: x2 not specified!'); end;
  if 1,           fprintf(fid,'%.2f ',boxes(o,4));
  else                                   error('ERROR: y2 not specified!'); end;

  % set 3D bounding box
  if 0,            fprintf(fid,'%.2f ',boxes(o).h);
  else                                   fprintf(fid,'-1 '); end; % default
  if 0,            fprintf(fid,'%.2f ',boxes(o).w);
  else                                   fprintf(fid,'-1 '); end; % default
  if 0,            fprintf(fid,'%.2f ',boxes(o).l);
  else                                   fprintf(fid,'-1 '); end; % default
  if 0,            fprintf(fid,'%.2f %.2f %.2f ',boxes(o).t);
  else                                   fprintf(fid,'-1000 -1000 -1000 '); end; % default
  if 0,           fprintf(fid,'%.2f ',wrapToPi(boxes(o).ry));
  else                                   fprintf(fid,'-10 '); end; % default

  % set score
  if 1,        fprintf(fid,'%.6f ',boxes(o,5));
  else                                   error('ERROR: score not specified!'); end;

  % next line
  fprintf(fid,'\n');
end

% close file
fclose(fid);
end
