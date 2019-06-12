function packageAnnotations()

    annosDir = '/home/gbmsu/Desktop/caltech/tools/data/Caltech__/test/annotations';
    %annosDir = '/home/gbmsu/Desktop/caltech/Caltechx10/test/anno_train10x_alignedby_RotatedFilters';
    tmpdir = '/home/gbmsu/Desktop/caltech/Caltechx10/train/tmp';
    savedir = '/home/gbmsu/Desktop/caltech/tools/code3.2.1/data-USA_new/annotations';
    
    %addpath(genpath('/home/gbmsu/Desktop/caltech/tools'));
    
    if (exist(savedir, 'dir')), rmdir(savedir, 's'); end
    
    sets = 6:10;
    vs = 0:20;
    
    for setind=1:length(sets)
       
        set = sprintf('set%.2d',sets(setind));
        
        for vsind=1:length(vs)
            
            v =  sprintf('V%.3d',vs(vsind));
            
            if (exist(tmpdir, 'dir')), rmdir(tmpdir, 's'); end
            mkdir_if_missing(tmpdir);
            
            annosfiles = dir([annosDir '/' set '_' v '*.txt']);
            
            for annoind=1:length(annosfiles)
                fname = annosfiles(annoind).name;
                iname = strrep(fname, '.txt', '');
                iname = strrep(iname, [ set '_' v '_I'], '');
                inum = str2num(iname);
                if mod(inum, 30) == 0
                    copyfile([annosDir '/' annosfiles(annoind).name], [tmpdir '/' annosfiles(annoind).name]);
                end
            end
            
            if length(annosfiles) > 0
                fprintf('%s%s\n', set, v);
                mkdir_if_missing([savedir '/' set]);
                A = vbb( 'vbbFrFiles', tmpdir);
                vbb('vbbSave', A, [savedir '/' set '/' v ]);
            end           
        end
    end
end