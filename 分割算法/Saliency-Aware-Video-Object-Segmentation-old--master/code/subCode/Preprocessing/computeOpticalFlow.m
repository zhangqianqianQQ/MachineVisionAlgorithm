% Wrapper to compute some given optical flow method
%
%    Copyright (C) 2013  Anestis Papazoglou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: a.papazoglou@sms.ed.ac.uk

function flow = computeOpticalFlow( options, frames)
    
    flowfolder = fullfile( options.outfolder, 'flow');
    if( ~exist( flowfolder, 'dir' ) )
        mkdir( flowfolder );
    end

    fprintf( 'computeOpticalFlow: \n');
    filename = fullfile( flowfolder, 'flow.mat');
    
    if( exist( filename, 'file' ) )
        % Shot already processed, skip
        fprintf( 'computeOpticalFlow: Data processed, skipping...\n' );
        flow = loadFlow( options );
        return;
    else 
        flowframes = length(frames)-1;
        flow = cell( 1, flowframes);
        totalTimeTaken = 0;
        for( i =  1: length(frames)-1 )
            tic
            currImage = frames{i};
            if( size( currImage, 3 ) == 1 )
                currImage = gray2rgb( currImage );
            end
            currImage = double( currImage );
            nextImage = frames{i+1};
            if( size( nextImage, 3 ) == 1 )
                nextImage = gray2rgb( nextImage );
            end
            nextImage = double( nextImage );

            if( options.vocal )
                fprintf( 'computeBroxPAMI2011Flow: Computing optical flow of pair: %i of %i... ', ...
                    i, length(frames)-1);
            end

            flowframe = mex_LDOF( im2double(currImage), im2double(nextImage) );
            flow{ i }( :, :, 1 ) = flowframe( :, :, 2 );
            flow{ i }( :, :, 2 ) = flowframe( :, :, 1 );
            timeTaken = toc;
            totalTimeTaken = totalTimeTaken + timeTaken;

            if( options.vocal )
                fprintf( 'done. Time taken: %.2f sec\n', timeTaken );
            end

        end

        if( options.vocal )
            fprintf( 'computeBroxPAMI2011Flow: Total time taken: %.2f sec\n', ...
                totalTimeTaken );
            fprintf( 'computeBroxPAMI2011Flow: Average time taken per frame: %.2f sec\n', ...
                totalTimeTaken / flowframes );
        end
        save( filename, 'flow', '-v7.3' );
    end    
    fprintf( 'computeOpticalFlow finished\n');
end
