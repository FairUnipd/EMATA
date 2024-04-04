function options=get_default_options()

    
    options.mask_volume_ICA = 1300; %mm3
    options.mask_volume_CCA = 25000;%30000;%22500;%mm3
    options.mask_volume_SSS = 4790; %mm3

    
%     options.nvoxs_ICA   = 80;
%     options.nvoxs_CCA   = 1400;
%     options.nvoxs_SSS   = 300;

    options.selected_volume_ICA = 300; %480; %mm3
    options.selected_volume_CCA = 640; %mm3
    
    options.add_tmode_ICA   =  0;
    options.add_tmode_CCA   = -1;
    options.clean_vols_up   =  3;
    options.clean_vols_down =  3;
    %options.late_vols=10;
    
    options.PseudoStatic_thr    = 30*60; %sec
    options.PseudoTOF_init_thr  = 60;%sec
    options.PseudoTOF_final_thr = [];

    options.ICA_priors = [0.1   0.0789   10    0.5    0.017]; %da modificare
    options.CCA_priors = [0.0444    0.0515   15.3611    0.3532    0.0095];

    
end