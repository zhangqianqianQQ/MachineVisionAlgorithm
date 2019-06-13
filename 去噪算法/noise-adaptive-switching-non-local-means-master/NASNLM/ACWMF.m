% ACWMF algorithm implementation
%function [y, noise_matrix] = ACWMF(I);
function output = ACWMF(I);


% Threshold parameters
%delta = [40 25 10 5];   %% for uniform impulse noise
delta = [55,40,25,15];  %% for salt and pepper noise
%delta = (delta1+delta2)/2;   %% for mixed impulse noise

x = double(I);
image_size = size(I);
B = im2col(padarray(x,[1 1],'symmetric','both'),[3 3],'sliding');

% Compute filter output
m = medfilt2(x,[3 3],'symmetric');

%Compute differences
d = abs(x-m);
d0 = d(:)';
clear d;
B(10,:) = x(:)';
B(11,:) = x(:)';
m1 = median(B);
d1 = abs(x(:)'-m1);
B(12,:) = x(:)';
B(13,:) = x(:)';
m1=median(B);
d2 = abs(x(:)'-m1);
B(14,:) = x(:)';
B(15,:) = x(:)';
m1=median(B);
d3 = abs(x(:)'-m1);
clear B;

% Compute MAD values
B_x = im2col(padarray(x,[1 1],'symmetric','both'),[3 3],'sliding');

for i = 1:9
    B(i,:) = abs(B_x(i,:) - m(:)');
end
MAD = median(B);

clear B;

% Compute threshold values
s = 0.1;
T1 = (MAD * s) + delta(1);
T2 = (MAD * s) + delta(2);
T3 = (MAD * s) + delta(3);
T4 = (MAD * s) + delta(4);

x2 = x(:);

% Detect noisy pixels
F = find((d0>T1)|(d1>T2)|(d2>T3)|(d3>T4));

%noise_matrix = zeros(image_size);
%noise_matrix(F) = 1;

% Replace noisy pixels
x2(F) = m(F);
clear F m d0 d1 d2 d3 T x;
output = uint8(col2im(x2,[1 1],image_size,'sliding')); 
 
