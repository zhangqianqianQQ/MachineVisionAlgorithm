function para=set_parameter(codebook,ratio)

if(~exist('codebook','var') || isempty(codebook))
    
    para_sc.model_height    = 150;
    para_sc.detector    = 'pb';
    para_sc.edge_bivalue= 0;
    if(strcmp(para_sc.detector,'pb'))
        para_sc.edge_thresh = 0.05;
    else
        para_sc.edge_thresh = 0.1;         
    end
    para_sc.bin_r   = [0,6,15];  
    para_sc.nb_bin_theta    = 12;
    para_sc.nb_ori  = 4;
    para_sc.blur_r	= 0.2;
    para_sc.blur_t	= 1.0;
    para_sc.blur_o  = 0.2;
    para_sc.blur_method = 'gaussian';
    para_sc.sum_total_thresh   = 5;
    para_sc.codebook_sample_step = 5;
    
    para    = para_sc;
    return;
else
    para_sc = codebook.para;
end


if(exist('ratio','var') && ratio>1)
    error('ratio cannot be bigger than 1.0');
end

model_height    = para_sc.model_height;


para_fea.ratio  = ratio;

para_fea.asp_ratio  = 2.1; 


para_fea.mask_fcn   = 1;

para_fea.K          = 8;


if(para_fea.asp_ratio>1)
    max_dim = model_height;
else
    max_dim = model_height/para_fea.asp_ratio;
end
para_fea.sample_step= [round(max_dim/18),round(max_dim/18)];


para_vote.vote_thresh   = 0.6;

para_vote.vote_disc_rad = max_dim*0.053;


para_vote.min_vote      = (model_height/para_fea.sample_step(2)) *...
    (model_height/para_fea.asp_ratio/para_fea.sample_step(1))* 0.2;

para_vote.nb_iter       = 2;

para_vote.elps_ab       = [(model_height/para_fea.asp_ratio)*0.15, model_height*0.15];

para_vote.maskRadius	= max(para_fea.sample_step);

para_vote.min_height    = model_height*(1-0.3);

para_vote.max_height    = model_height*(1+0.3);

para_vote.vote_offset   = max(max(abs(codebook.relpos))) + 5;
voter_filter            = compute_smth_kernel(model_height, para_fea.asp_ratio);

para_vote.voter_filter  = voter_filter{1};

para{1} = para_sc;
para{2} = para_fea;
para{3} = para_vote;
