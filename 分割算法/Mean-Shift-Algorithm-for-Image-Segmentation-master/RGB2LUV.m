
% formulas for the conversions were taken from the wikipedia

function [ L,U,V ] = RGB2LUV(R,G,B)

var_R = double( R )/ 255 ;       
var_G = double( G )/ 255  ;       
var_B = double( B )/ 255   ;  

if ( var_R >0.04045 ) 
    var_R = ( ( var_R + 0.055 ) / 1.055 )^2.4;
else
    var_R = var_R / 12.92;
end
if ( var_G > 0.04045 ) 
    var_G = (( var_G + 0.055 )/1.055 )^2.4;
else
    var_G = var_G / 12.92;
end
if ( var_B > 0.04045 ) 
    var_B = ( ( var_B + 0.055 ) / 1.055 )^2.4;
    
else
    var_B = var_B / 12.92;
end

var_R = var_R * 100;
var_G = var_G * 100;
var_B = var_B * 100;

X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;

%XYZ to LUV
var_U = ( 4 * X ) / ( X + ( 15 * Y ) + ( 3 * Z ) );
var_V = ( 9 * Y ) / ( X + ( 15 * Y ) + ( 3 * Z ) );

var_Y = Y / 100;
if ( var_Y > 0.008856 ) 
    var_Y = var_Y^( 1/3 );
else
    var_Y = ( 7.787 * var_Y ) + ( 16 / 116 );
end

ref_X =  95.047;       
ref_Y = 100.000;
ref_Z = 108.883;

ref_U = (4*ref_X )/(ref_X+( 15 * ref_Y ) + ( 3 * ref_Z ) );
ref_V = (9*ref_Y )/(ref_X+( 15 * ref_Y ) + ( 3 * ref_Z ) );

L1 = (116*var_Y)-16;
U1 = 13*L1*(var_U-ref_U );
V1 = 13*L1*(var_V-ref_V );
L1(isnan(L1))=0;
U1(isnan(U1))=0;
V1(isnan(V1))=0;
L=L1;
U=U1;
V=V1;

end
