% This is a demo script to run EMATA on OPENNEURO dataset: 
% Gabriel Castrillon and Samira Epp and Antonia Bose and Laura Fraticelli 
% and André Hechler and Roman Belenya and Andreas Ranft and Igor Yakushev 
% and Lukas Utz and Lalith Sundar and Josef P Rauschecker 
% and Christine Preibisch and Katarzyna Kurcyus and Valentin Riedl (2023).
% The energetic costs of the human connectome. OpenNeuro.
% [Dataset] doi: doi:10.18112/openneuro.ds004513.v1.0.4
% To run the script dataset needs to be downloaded locally on your machine

% add EMATA to yout path
% addpath(genpath(...))
%% Preparing DATA

DATASET_root        = ''; %insert path where dataset is stored
DATASET_info_path   = fullfile(DATASET_root,"participants.tsv");


subj_name           = 'sub-s003'; %or insere the subject you wish to process
session_name        = 'ses-open';
subj_PET_path       = fullfile(DATASET_root,subj_name,session_name,'pet');
PETDYN_path         = fullfile(subj_PET_path,[subj_name '_' session_name '_task-rest_pet.nii.gz']);
PETDYN_info_path    = fullfile(subj_PET_path,[subj_name '_' session_name '_task-rest_pet.json']);
AIF_subj_path       = fullfile(subj_PET_path,[subj_name '_' session_name '_task-rest_recording-autosampler_blood.tsv']);


tool_out_path       = fullfile(subj_PET_path,'emata_out'); % or whatever you prefer

if ~exist(tool_out_path,'dir')

    mkdir(tool_out_path)

end

%loading info
PET_INFO = jsondecode(fileread(PETDYN_info_path));


% time
t_PET_delta = PET_INFO.FrameDuration;

%loading covariates for NLMEM
demographic_info = readtable(DATASET_info_path,'FileType','text','Delimiter','\t');

idx_subject = cell2mat(cellfun(@(x) string(x) == string(subj_name), demographic_info.participant_id,'UniformOutput',false));
idx_session = cell2mat(cellfun(@(x) string(x) == session_name, demographic_info.session_id,'UniformOutput',false));

idx_subj_session = find(idx_subject & idx_session);

age     = table2array(demographic_info(idx_subj_session,"age")); % years
sex     = cell2mat(table2array(demographic_info(idx_subj_session,"sex"))); % M/F
height  = table2array(demographic_info(idx_subj_session,"body_height")); %meters
weight  = table2array(demographic_info(idx_subj_session,"body_weight")); %Kg

dose    = PET_INFO.InjectedRadioactivity; %MBq

if sex == 'M'
    sex = 0;
else
    sex = 1;
end

height = height*100;

covariates = [sex height weight age dose];

%loading AIF
AIF_table = readtable(AIF_subj_path,'FileType','text','Delimiter','\t');

AIF.c = AIF_table.plasma_radioactivity';
AIF.t = AIF_table.time';

%% Running EMATA

try

    %ICA
    emata(PETDYN_path, t_PET_delta', tool_out_path,'extractionSite','ICA', 'Chen', 'NLMEM', covariates,'options',options_path);

    close all

    %CCA
    emata(PETDYN_path, t_PET_delta', tool_out_path,'extractionSite','CCA', 'Chen', 'NLMEM', covariates,'options',options_path);

    close all
    
    %AIF-based
    emata(PETDYN_path, t_PET_delta', tool_out_path,"InputFun",'AIF',AIF,'options',options_path);

catch e

    disp(['Subject: ' subj_name ' cannot be processed because of the following error!'])
    disp(e)

end

