% Function to load the superpixel oversegmentation of given method
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

function superpixels = loadSuperpixels( options )

    file = fullfile( options.outfolder, 'superpixels', 'superpixels.mat' );
    if( exist( file, 'file' ) )
        superpixels = load( file );
        if( isfield( superpixels, 'input' ) )
            superpixels = superpixels.input;
        elseif( isfield( superpixels, 'superpixels' ) )
            superpixels = superpixels.superpixels;
        elseif( isfield( superpixels, 'superPixels' ) )
            superpixels = superpixels.superPixels;
        else
        		warning( '%s: no known field found\n', file );
            superpixels = [];
        end
    else
        warning( '%s not found\n', file );
        superpixels = [];
    end
    
end
