function [candidate_pos] = get_candidate_pos(valid_idx, scoresK_id, relpos, testpos)


nb_test = size(testpos,1);
testpos_idx = mod(valid_idx-1, nb_test) + 1;

candidate_pos   = zeros(length(valid_idx),2);
scoresK_id      = scoresK_id(valid_idx);
relpos          = relpos(scoresK_id,:);
testpos         = testpos(testpos_idx,:);
candidate_pos   = testpos+relpos;

