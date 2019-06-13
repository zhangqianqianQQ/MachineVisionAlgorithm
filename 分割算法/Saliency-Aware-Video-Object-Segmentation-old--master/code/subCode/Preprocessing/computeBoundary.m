function boundary = computeBoundary( options, frames)
    
    boundaryfolder = fullfile( options.outfolder, 'boundary');
    if( ~exist( boundaryfolder, 'dir' ) )
        mkdir( boundaryfolder );
    end

    fprintf( 'computeBoundary: \n');
    filename = fullfile( boundaryfolder, 'boundary.mat');
    
    if( exist( filename, 'file' ) )
        % Shot already processed, skip
        fprintf( 'computeBoundary: Data processed, skipping...\n' );
        boundary = loadBoundary( options );
        return;
    else 
        boundaryframes = length(frames)-1;
        boundary = cell( 1, boundaryframes);
        totalTimeTaken = 0;
        for( i =  1: length(frames)-1 )
            tic
            currImage = frames{i};
%             currImage = double( currImage );
            if( options.vocal )
                fprintf( 'computeGb_Oct2012: Computing boundary of frame: %i of %i... ', ...
                    i, length(frames)-1);
            end
            [gb_thin_CSG, gb_thin_CS, gb_CS, orC, edgeImage, edgeComponents] = Gb_CSG(currImage);                      
            boundary{ i } = gb_CS;
            timeTaken = toc;
            totalTimeTaken = totalTimeTaken + timeTaken;
            if( options.vocal )
                fprintf( 'done. Time taken: %.2f sec\n', timeTaken );
            end

        end
        if( options.vocal )
            fprintf( 'computeGb_Oct2012: Total time taken: %.2f sec\n', ...
                totalTimeTaken );
            fprintf( 'computeGb_Oct2012: Average time taken per frame: %.2f sec\n', ...
                totalTimeTaken / boundaryframes );
        end
        save( filename, 'boundary', '-v7.3' );
    end    
    fprintf( 'computeBoundary finished\n');
end
