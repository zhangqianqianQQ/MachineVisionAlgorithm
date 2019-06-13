IN_DIR = 'images/stacked';
OUT_DIR = 'images/detected';
mkdir(OUT_DIR);
N = 88;

for i = 1 : N
    fn = sprintf('%s/%d.jpg', IN_DIR, i);
    I = imread(fn);
    detectEllipses(I);
    saveas(gcf, sprintf('%s/%d.png', OUT_DIR, i));
    close;
end
