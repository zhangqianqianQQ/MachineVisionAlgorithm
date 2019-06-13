function result = loadBoundary( options)

    file = fullfile( options.outfolder, 'boundary', 'boundary.mat' );
    if( exist( file, 'file' ) )
        boundary = load( file );
        if( isfield( boundary, 'input' ) )
            result = boundary.input;
        elseif( isfield( boundary, 'boundary' ) )
            result = boundary.boundary;
        else
            warning( '%s: no known field found\n', file );
            result = [];
        end
    else
        warning( '%s not found\n', file );
        result = [];
    end

end
