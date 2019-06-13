function HT = SoftThreshold(input,H);
% HT = input;
% for i = 1:numel(input)
%     if abs(input(i)) < H
%         HT(i) = 0;
%     end
%     if abs(input(i)) > H
%         HT(i) = sign(input(i))*(abs(input(i))-H);
%     end
% end
HT = sign(input).*max(abs(input)-H,0);
end