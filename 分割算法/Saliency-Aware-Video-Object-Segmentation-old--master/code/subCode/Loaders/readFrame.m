% Function to load a particular frame
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

function frame = readFrame( options, index )

    if( ~isfield( options, 'stored' ) )
        if( isfield( options, 'infolder' ) && ...
            ~isfield( options, 'videoObject' ) )
            options.stored = true;
        else
            options.stored = false;
        end
    end

    if( options.stored )
        filename = fullfile( options.infolder, sprintf( ...
            '%08d.jpg', index ) );
        if( exist( filename, 'file' ) )
            frame = imread( filename );
        else
            error( 'Frame "%s" cannot be found.', filename );
        end
    else
        frame = read( options.videoObject, options.uniqueFrames( index ) );
    end
    
    [ height, width, channels ] = size( frame );
    
    % Make sure that the image is in colour
    if( channels == 1 )
        frame = gray2rgb( frame );
    end
    
    % Check whether the frame should be resized
    if( isfield( options, 'maxedge' ) )
        edge = max( height, width );
        
        if( edge > options.maxedge )
            scale = options.maxedge / edge;
            frame = imresize( frame, scale, 'Antialiasing', false );
        end
    end
end
