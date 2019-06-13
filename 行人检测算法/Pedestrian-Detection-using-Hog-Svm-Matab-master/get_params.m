function params = get_params(file_name)
% GET_PARAMS retrieve params saved in a .mat file  
%  
% INPUT:
%       file_name: path of the file to load 
%
%$ Author: Jose Marcos Rodriguez $ 
%$ Date: 16-Dec-2013 17:16:31 $ 
%$ Revision : 1.00 $ 
%% FILENAME  : get_params.m 

   % Testing if param file exists in the params directory
    if exist(['params',filesep,strcat(file_name,'.mat')],'file')
        params = load(['params',filesep,strcat(file_name,'.mat')]);

    % Testing if param file exists in the current directory
    elseif exist(strcat(file_name,'.mat'),'file')
        params = load(strcat(file_name,'.mat'));

    % Dialog to select param file
    else
        [param_file,PathName,~] = uigetfile('*.mat',strcat('Select parameter file (',file_name,')'));
        if ~isa(param_file,'double')
            params = load([PathName,filesep,param_file]);
        else
            cprintf('Errors','Missing param file...\nexiting...\n\n');
            return
        end
    end

end
