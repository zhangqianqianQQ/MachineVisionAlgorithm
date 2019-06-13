function tmp = rotatePC(pc,R)

if(isequal(R,eye(3)))
    tmp = pc;
else
	pc = permute(pc,[3 1 2]);
	tmp = reshape(pc,[3 numel(pc)/3]);
	tmp = R*tmp;
	tmp = reshape(tmp, size(pc));
	tmp = permute(tmp,[2 3 1]);
	pc = tmp;
end

end
