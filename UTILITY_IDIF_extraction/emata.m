%
%emata(PET_dyn_path, t_PET_delta, out_path)
%
%Optional parameters
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'MoCo', MOCO_flag)
% MOCO_flag = 1 or 0 (default = 1)
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'Patlak', PATLAK_flag)
% PATLAK_flag = 1 or 0 (default = 1)
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'extractionSite', site)
% site = 'ICA' (default) or 'CCA'
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'InputFun', 'IDIF', 'extractionSite', site)
% site = 'ICA' (default) or 'CCA'
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'InputFun', 'AIF', AIF_struct)
% AIF_struct =
%   AIF.c  [Bq/ml]
%   AIF.t  [sec]
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'InputFun', 'AIF', AIF_struct, 'Feng', doFeng)
% AIF_struct =
%   AIF.c  [Bq/ml]
%   AIF.t  [sec]
% doFeng = 1 or 0 (default = 1)
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'InputFun', 'IDIF', 'extractionSite', site, 'Feng', doFeng)
% site = 'ICA' (default) or 'CCA'
% doFeng = 1 or 0 (default = 1)
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'Feng', doFeng)
% doFeng = 1 or 0 (default = 1)
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'Chen', 'NLMEM', covariates)
% covariates = [Sex Height Weight Age Dose];
%   Sex --> 1: female, 0: male
%   Height [cm]
%   Weight [Kg]
%   Age [years]
%   Dose[MBq]
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'Chen', 'samples', venous_samples)
% venous_samples =
%   venous_samples.c [Bq/ml]
%   venous_samples.t [sec]
%
%emata(PET_dyn_path, t_PET_delta, out_path, 'options', options_path)
%options_path <-- .json file path for tuning parameters

function emata(PET_dyn_path, t_PET_delta, out_path, varargin)

%% setting default options

extraction_Site_in = 0;

MOCO_FLAG   = 1;
input_fun   = 'IDIF';
IDIF_FLAG   = 1;
AIF_FLAG    = 0;
anatomy     = 'ICA';
FENG_FLAG   = 1;
CHEN_FLAG   = 0;
PATLAK_FLAG = 1;
options_path = 'options.json';
enable_advanced_graphics = 0;

t_PET_emi = cumsum(t_PET_delta) - t_PET_delta/2;

%% External parameters

while not(isempty(varargin))


    switch varargin{1}

        case 'MoCo'

            MOCO_FLAG = 0;
            varargin(1) = [];

            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument after MoCo: 1 or 0');
                throw(exception);

            end

            if varargin{1} ~= 0

                MOCO_FLAG = 1;

            end

            varargin(1) = [];


        case 'InputFun'

            varargin(1) = [];

            input_fun = varargin{1};

            switch varargin{1}

                case 'AIF'

                    AIF_FLAG = 1;
                    anatomy  = '';
                    IDIF_FLAG = 0;

                    varargin(1) = [];

                    if isempty(varargin)

                        exception=MException('IDIF_extraction_tool:Fail','Expected argument: [AIF.t AIF.c] ');
                        throw(exception);

                    end

                    AIF = varargin{1};

                    varargin(1) = [];

                case 'IDIF'

                    IDIF_FLAG = 1;
                    AIF_FLAG  = 0;
                    varargin(1) = [];

                otherwise

                    exception=MException('IDIF_extraction_tool:Fail',['Unknown ' varargin{1}]);
                    throw(exception);

            end


        case 'extractionSite'


            varargin(1) = [];

            extraction_Site_in = 1;


            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument after ExtractionSite (ICA/CCA)');
                throw(exception);


            end

            anatomy = varargin{1};


            if not((strcmp(anatomy,'ICA') || strcmp(anatomy,'CCA')))

                exception=MException('IDIF_extraction_tool:Fail','Unknown extraction site for IDIF estimation');
                throw(exception);


            end


            varargin(1) = [];

        case 'Feng'

            FENG_FLAG = 0;
            varargin(1) = [];

            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument after Feng: 1 or 0');
                throw(exception);

            end

            if varargin{1} ~= 0

                FENG_FLAG = 1;

            end

            varargin(1) = [];

        case 'Chen'

            CHEN_FLAG   = 1;
            varargin(1) = [];

            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument for Chen Correction: NLMEM or samples');
                throw(exception);


            end

            Chen_mode = varargin{1};

            switch(varargin{1})

                case 'NLMEM'

                    varargin(1) = [];

                    if isempty(varargin)

                        exception=MException('IDIF_extraction_tool:Fail','Expected argument for NLMEM: covariates');
                        throw(exception);


                    end

                    covariates = varargin{1};

                    varargin(1) = [];

                case 'samples'

                    varargin(1) = [];

                    if isempty(varargin)

                        exception=MException('IDIF_extraction_tool:Fail','Expected argument for Chen correction: decay corrected venous samples');
                        throw(exception);


                    end

                    venous_samples = varargin{1};

                    varargin(1) = [];

                otherwise

                    exception=MException('IDIF_extraction_tool:Fail',['Unknown ' varargin{1}]);
                    throw(exception);


            end

        case 'Patlak'

            PATLAK_FLAG = 0;
            varargin(1) = [];

            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument after Patlak: 1 or 0');
                throw(exception);

            end

            if varargin{1} ~= 0

                PATLAK_FLAG = 1;

            end

            varargin(1) = [];



        case 'options'

            varargin(1) = [];

            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument: options path');
                throw(exception);


            end

            options_path = varargin{1};

            varargin(1) = [];

        case 'EnableAdvancedGraphics'

            enable_advanced_graphics = 0;
            varargin(1) = [];

            if isempty(varargin)

                exception=MException('IDIF_extraction_tool:Fail','Expected argument after EnableAdvancedGraphics: 1 or 0');
                throw(exception);

            end

            if varargin{1} ~= 0

                enable_advanced_graphics = 1;

            end

            varargin(1) = [];




        otherwise

            exception=MException('IDIF_extraction_tool:Fail',['Unknown ' varargin{1}]);
            throw(exception);


    end






end

%% Checking for inconsistencies in given parameters

if strcmp(input_fun,'AIF')

    if CHEN_FLAG

        disp('Chen correction is not required for AIF. Option will be ignored');

    end

    if extraction_Site_in

        disp('extraction site segmentation is not necessary when using external AIF. Option will be ignored')
        anatomy = '';

    end


end


%% OUT PATH PREPARATION

[modelfit_path,temp_path,maps_path,IDIF_path, IDIFTemp_path, IDIFVessels_path, IDIFQC_path, MOCO_path, SEG_path, COREG_path] = out_path_preparation(out_path);


%% loading options

options = get_options(options_path);

options.advanced_graphics_enabled = enable_advanced_graphics;

%% MOCO + PSEUDO-STATIC

IN_PET_dyn = PET_dyn_path;

if MOCO_FLAG

    disp('Motion Correction...')

    [~, fname, ext]  = fileparts(IN_PET_dyn);
    [~, fname, ~]      = fileparts(fname);
    outfile_MOCO     = fullfile(MOCO_path, [fname '_MoCo.nii.gz']);

    if ~exist(outfile_MOCO)

        iframe_sec = options.MoCo_start;

        tgframe = find(cumsum(t_PET_delta)>=iframe_sec,1,'first'); % target frame for motion correction step
        iframe  = tgframe; % initial frame for motion correction step
        fframe  = length(t_PET_delta); % final frame form motion correction step

        outfile_MOCO = motion_correction_fsl(PET_dyn_path, MOCO_path, tgframe, iframe, fframe);
    else

        disp('Motion Correction has been already performed! Skipping to the next step!')

    end

    IN_PET_dyn = outfile_MOCO;

end


% Pseudo_STATIC

generate_pseudo_static_PET(IN_PET_dyn,t_PET_emi, COREG_path, options);

% COREG

mni2sub(COREG_path);

%% INPUT FUNCTION

switch(input_fun)


    case 'AIF'



    case 'IDIF'

        %% Segmentation

        % SEGMENT

        segment_arteries(IN_PET_dyn, t_PET_emi, out_path, anatomy,options);

        %% Extraction (raw IDIF)

        disp('IDIF Extraction...');

        IDIF_extraction_wrapper(IN_PET_dyn, t_PET_emi, t_PET_delta, anatomy, IDIFQC_path, IDIFVessels_path, IDIF_path, options);


        %% Feng

        if FENG_FLAG

            disp ('Feng Fitting...')



            Feng_fit = feng_fit_wrapper(IDIF_path,IDIFQC_path,anatomy,options);



        end

        %% Chen



        if CHEN_FLAG

            disp ('Chen Fitting...')

            generate_BG_tissue_mask(anatomy,IN_PET_dyn,t_PET_emi,3,IDIFTemp_path,IDIFQC_path,IDIFVessels_path,options);



            switch(Chen_mode)

                case 'NLMEM'

                    t_fit = 20*60:1:t_PET_emi(end);

                    venous_model_fit = NLMEM_wrapper(covariates, t_fit, IDIFQC_path,IDIFTemp_path);

                    venous_time = venous_model_fit.t;
                    venous = venous_model_fit.c*1000;


                case 'samples'

                    venous_time = venous_samples.t;
                    venous = venous_samples.c;


            end

            %Chen correction
            Chen_correction_wrapper(venous,venous_time, IDIF_path, IDIFTemp_path, IDIFQC_path,anatomy);



        end
end

%% Patlak

if PATLAK_FLAG

    disp('Patlak...')

    BRAIN_path = fullfile(COREG_path,'FDG_SUVR_cereb_template_flirt_out.nii.gz');

    if IDIF_FLAG == 1

        load(fullfile(IDIF_path,['IDIF_' anatomy '.mat']));

        Cp      = IDIF.IDIF;
        Cp_time = IDIF.t_IDIF;

    else

        Cp      = AIF.c;
        Cp_time = AIF.t;

    end

    Patlak_wrapper(IN_PET_dyn, t_PET_emi, t_PET_delta, BRAIN_path, Cp, Cp_time, anatomy, maps_path, options);


end

%mni2sub_GM_WM(COREG_path);





