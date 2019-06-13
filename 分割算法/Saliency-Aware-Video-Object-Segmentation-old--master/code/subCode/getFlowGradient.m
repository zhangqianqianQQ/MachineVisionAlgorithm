% Function to compute the gradient of the given optical flow
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

function result = getFlowGradient( flow )

    if( iscell( flow ) )
        framesNumber = length( flow );
    
        gradients = cell( 1, framesNumber );
        for( i = 1: framesNumber )
            grad( :, :, 1 ) = gradient( single( flow{ i }( :, :, 1 ) ) );
            [ ~, grad( :, :, 2 ) ] = ...
                gradient( single( flow{ i }( :, :, 2 ) ) );
        
            gradients{ i } = grad;
        end
        result = gradients;
    else
        [ height, width, ~ ] = size( flow );
        grad = zeros( height, width, 2, 'single' );
        if( ~isfloat( flow ) )
            flow = single( flow );
        end
        
        grad( :, :, 1 ) = gradient( flow( :, :, 1 ) );
        [ ~, grad( :, :, 2 ) ] = gradient( flow( :, :, 2 ) );
        
        result = grad;
    end
end
