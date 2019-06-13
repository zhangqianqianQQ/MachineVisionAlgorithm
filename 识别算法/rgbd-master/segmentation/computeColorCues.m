function [bg, cga, cgb, tg] = computeDepthCues(I, colorParam)
	[mPb_nmax, mPb_nmax_rsz, bg1, bg2, bg3, cga1, cga2, cga3, cgb1, cgb2, cgb3, tg1, tg2, tg3, textons] = multiscalePb(im2double(I));
	
	bg = cat(4, bg1, bg2, bg3);
	tg = cat(4, tg1, tg2, tg3);
	cgb = cat(4, cgb1, cgb2, cgb3);
	cga = cat(4, cga1, cga2, cga3);
end
