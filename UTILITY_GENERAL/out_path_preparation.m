function [modelfit_path,temp_path,maps_path,IDIF_path, IDIFTemp_path, IDIFVessels_path, IDIFQC_path, MOCO_path, SEG_path, COREG_path]=out_path_preparation(destination_dir)


%% ModelFit
modelfit_path=fullfile(destination_dir,'ModelFit');

if(not(isfolder(modelfit_path)))
    mkdir(modelfit_path);
end

% subdirectories
temp_path=fullfile(modelfit_path,'Temp');

if(not(isfolder(temp_path)))
    mkdir(temp_path);
end


maps_path=fullfile(modelfit_path,'Maps');

if(not(isfolder(maps_path)))
    mkdir(maps_path);
end

%% IDIF PATH

IDIF_path=fullfile(destination_dir,'IDIF');

if(not(isfolder(IDIF_path)))
    mkdir(IDIF_path);
end

% subdirectiories

IDIFTemp_path=fullfile(IDIF_path,'Temp');

if(not(isfolder(IDIFTemp_path)))
    mkdir(IDIFTemp_path);
end

IDIFVessels_path=fullfile(IDIF_path,'Vessels');

if(not(isfolder(IDIFVessels_path)))
    mkdir(IDIFVessels_path);
end

IDIFQC_path=fullfile(IDIF_path,'QC');

if(not(isfolder(IDIFQC_path)))
    mkdir(IDIFQC_path);
end

%% Segmentation PATH

SEG_path=fullfile(destination_dir,'Segmentation');

if(not(isfolder(SEG_path)))
    mkdir(SEG_path);
end

%% Motion Correction PATH 

MOCO_path=fullfile(destination_dir,'Motion_Correction');

if(not(isfolder(MOCO_path)))
    mkdir(MOCO_path);
end

%% COREG PATH 

COREG_path=fullfile(destination_dir,'COREG');

if(not(isfolder(COREG_path)))
    mkdir(COREG_path);
end


end
