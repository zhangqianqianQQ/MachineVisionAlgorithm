function merged_imsegs = GetMergedImsegs( imsegs, splabel )
    assert( imsegs.nseg == length(splabel) );
    trans_splabel = TransformLabelRange( splabel );
    
    segimage = zeros( size(imsegs.segimage) );
    
    spstats = regionprops( imsegs.segimage, 'PixelIdxList' );
    
    for ix = 1 : length(spstats)
        segimage(spstats(ix).PixelIdxList) = trans_splabel(ix);
    end
    
    merged_imsegs.segimage = segimage;
    merged_imsegs.nseg = length(unique(splabel));
    
    merged_imsegs = APPgetSpStats( merged_imsegs );
end

function out_array = TransformLabelRange( in_array )
    % transform in_array to out_array, where the elements of in_array are
    % in the range [1 length(in_array)]
    elem = unique(in_array);
    nelem = length(elem);
    
    out_array = in_array;
    for ix = 1 : nelem
        out_array(in_array == elem(ix)) = ix;
    end
end