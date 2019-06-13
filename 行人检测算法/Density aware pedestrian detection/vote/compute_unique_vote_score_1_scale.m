function [ recog_result ] = compute_unique_vote_score_1_scale( recog_result,para_fea)

score_list  = recog_result.score_list;
voterec = recog_result.voterec;

scoresK     = recog_result.scoresK;
scoresK_id  = recog_result.scoresK_id;
testpos     = recog_result.testpos;
valid_vote_idx=recog_result.valid_vote_idx;

nb_hypo     = length(voterec);
nb_test     = size(testpos,1);

for hypo=1:nb_hypo
    voter_id        = voterec(hypo).voter_id;
    v_id            = valid_vote_idx(voter_id);
    [test_id,K_id]  = ind2sub([nb_test,para_fea.K], v_id);

    code_id     = scoresK_id(v_id);
    [uni_code_id,code_m,code_n] = unique(code_id);
    [uni_test_id,test_m,test_n] = unique(test_id);
    nb_voter    = length(test_m);
    nb_code     = length(code_m);
    A           = ones(nb_voter, nb_code)*2;
    uni_id      = sub2ind([nb_voter,nb_code],test_n,code_n);
    A(uni_id)   = 1 - scoresK(v_id);

    [cost,t_id,c_id]= myhungarian(A, 2);    
    new_score   = length(t_id)  - cost;
    nb_voter_new= length(t_id);
    new_voter_id= zeros(nb_voter_new,1);
    uni_test_id = uni_test_id(t_id);
    uni_code_id = uni_code_id(c_id);
    for vv=1:nb_voter_new
        match_id= find(test_id==uni_test_id(vv));
        cc  = find(scoresK_id(v_id(match_id))==uni_code_id(vv));
        new_voter_id(vv)= match_id(cc);
    end
    voterec(hypo).voter_id  = voter_id(new_voter_id);
    score_list(hypo)    = new_score;
   
end

recog_result.voterec  = voterec;
recog_result.score_list   = score_list;
