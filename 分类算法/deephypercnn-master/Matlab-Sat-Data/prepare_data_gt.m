function prepare_data_gt(input_files, output_file_name, pca_dim)

%load the hyperspectral data
mat_load=load(input_files.data_file);
fields=fieldnames(mat_load);
fields=fields{1};
im=getfield(mat_load,fields);

%load the labels
gt_load=load(input_files.gt_file);
fields=fieldnames(gt_load);
fields=fields{1};
ip_gt=getfield(gt_load,fields);

%get statistics of the data
[h,w,ch]=size(im)
num_pix=length(find(ip_gt>0));%h*w;

im_cen=im;

%pad the im_cen
conv_size=5;
pad_no=(conv_size-1)/2;

%padded image
im_X=zeros(h+2*pad_no,w+2*pad_no,ch);
for i=1:ch
    im_i=im_cen(:,:,i);
    im_X(:,:,i)=padarray(im_i,[pad_no,pad_no],'symmetric');
end

ip_gt_pad=padarray(ip_gt,[pad_no,pad_no],'symmetric');

cnt=1;
X=zeros(num_pix,ch,conv_size,conv_size);
labels=zeros(num_pix,1);
verbose=false;

for y=1:h
    fprintf('\nRow num=%d of %d',y,h);
    for x=1:w
        if ip_gt(y,x)>0
             X(cnt,:,:,:)=permute(im_X(y:y+conv_size-1,x:x+conv_size-1,:),...
                [3,1,2]);
            labels(cnt)=ip_gt(y,x);

            if verbose
                figure(1);
                imagesc(ip_gt_pad);
                rectangle('Position',[x y conv_size conv_size],...
                    'EdgeColor','r','linewidth',2);
                title(sprintf('Label=%d',labels(cnt)));
            end
            drawnow;
            pause(0.01);
            cnt=cnt+1;
        end
    end
end


comp=pcExtract(permute(X,[2,1,3,4]),pca_dim);
X_r=permute(comp,[2,1,3,4]);


save(output_file_name,'X_r','labels','ip_gt','im','-v7.3');
