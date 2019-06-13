%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is used to extract probability for test samples from test.log file
% For Indian Pines image as examples, the input is "test_indian_pines.log",
% the output is "indian_pines_probs".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc
%%%%%%%%%%%%%%%%  extracting probabilty from test.log by using sh %%%%%%%%

%%%%%%%%%%%%%%%%%  for Indian Pines image  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ! rm -r info/indian_pines_prob.txt
% ! cp info/test_indian_pines.log test_data.log
% ! cat test_data.log | grep "Batch ., prob" | awk '{print $9}' >& temp1.txt
% ! cat test_data.log | grep "Batch .., prob" | awk '{print $9}' >& temp2.txt
% ! cat test_data.log | grep "Batch ..., prob" | awk '{print $9}' >& temp3.txt
% ! cat temp3.txt >> temp2.txt
% ! cat temp2.txt >> temp1.txt
% ! cat temp1.txt >> info/indian_pines_prob.txt
% ! rm -r test_data.log temp1.txt temp2.txt temp3.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%  for University of Pavia %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
! rm -r info/paviau_prob.txt
! cp info/test_paviau.log test_data.log
! cat test_data.log | grep "Batch ., prob" | awk '{print $9}' >& temp1.txt
! cat test_data.log | grep "Batch .., prob" | awk '{print $9}' >& temp2.txt
! cat test_data.log | grep "Batch ..., prob" | awk '{print $9}' >& temp3.txt
! cat test_data.log | grep "Batch ...., prob" | awk '{print $9}' >& temp4.txt
! cat temp4.txt >> temp3.txt
! cat temp3.txt >> temp2.txt
! cat temp2.txt >> temp1.txt
! cat temp1.txt >> info/paviau_prob.txt
! rm -r test_data.log temp1.txt temp2.txt temp3.txt temp4.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%  for Salinas image   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ! rm -r info/salinas_prob.txt
% ! cp info/test_salinas.log test_data.log
% ! cat test_data.log | grep "Batch ., prob" | awk '{print $9}' >& temp1.txt
% ! cat test_data.log | grep "Batch .., prob" | awk '{print $9}' >& temp2.txt
% ! cat test_data.log | grep "Batch ..., prob" | awk '{print $9}' >& temp3.txt
% ! cat test_data.log | grep "Batch ...., prob" | awk '{print $9}' >& temp4.txt
% ! cat temp4.txt >> temp3.txt
% ! cat temp3.txt >> temp2.txt
% ! cat temp2.txt >> temp1.txt
% ! cat temp1.txt >> info/salinas_prob.txt
% ! rm -r test_data.log temp1.txt temp2.txt temp3.txt temp4.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
