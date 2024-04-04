function motion_corrected_name = FSL_MoCo_batch(filename,tgframe,iframe,fframe)
%======================
%	  -file input
%======================
fprintf(1,' \n   Reading Volume ...');
DYN = load_untouch_nii(filename);
DYN = double(DYN.img);
fprintf(1,' done.');

[inpath, fname, ~]  = fileparts(filename);
[~, fname, ~]      = fileparts(fname);

DIM             = size(DYN);

%%

%=====================
%	  -re-aligning 
%=====================

IN                  = convertpath2lnx(fullfile(inpath,'temp.nii.gz'));
REF                 = convertpath2lnx(fullfile(inpath,'REF.nii.gz'));
OUT                 = convertpath2lnx(fullfile(inpath,'temp_MoCo'));
transf_folder       = convertpath2lnx(fullfile(inpath,'temp_MoCo.mat'));
singleMoCo_folder   = convertpath2lnx(fullfile(inpath,[fname '_MoCo_single']));

imgs_2_write        = DYN(:,:,:,iframe:fframe);
nii                 = load_untouch_nii(filename);
nii.img             = imgs_2_write;
nii.hdr.dime.dim(5) = size(imgs_2_write,4);
nii.hdr.dime.glmax  = max(imgs_2_write(:));
nii.hdr.dime.glmax  = min(imgs_2_write(:));
save_untouch_nii(nii,IN)

fprintf(1,'\n Reference extraction ... ');
cmdprfx = get_fsl_command('fslroi');
cmd2execute = convertcmd2lnx([cmdprfx ' ' convertpath2lnx(filename) ' ' REF ' ' num2str(tgframe-1) ' 1 ']);
system(cmd2execute);
fprintf(1,'done.');

fprintf(1,'\n Estimating motion-correction transforms ... ');
cmdprfx = get_fsl_command('mcflirt');
cmd2execute = convertcmd2lnx([cmdprfx ' -in ' IN ' -out ' OUT ' -reffile ' REF ' -mats -plots -dof 6 -cost leastsquares']);
system(cmd2execute);
fprintf(1,'done.');

fprintf(1,'\n Applying MoCo transforms frame by frame ... \n');

mkdir(singleMoCo_folder)

% Split filename into frames
cmdprfx = get_fsl_command('fslsplit');
cmd2execute = convertcmd2lnx([cmdprfx ' ' convertpath2lnx(filename) ' ' convertpath2lnx(fullfile(singleMoCo_folder,[fname '_' ])) ' -t ']);
system(cmd2execute);

for frame = 1: DIM(4)      
    clear tmp tmp_MoCo pos
    fprintf(1,['   Volume no. ' sprintf('%02d',frame-1) ' \n']);
    tmp      = convertpath2lnx(fullfile(singleMoCo_folder, [fname '_' sprintf('%04d',frame-1)]));
    tmp_MoCo = convertpath2lnx(fullfile(singleMoCo_folder, [fname '_' sprintf('%04d',frame-1) '_MoCo']));
    
    % Selecting transform to be applied
    if(frame < iframe)
        pos = 0;
    elseif((frame>=iframe)&(frame<=fframe))
        pos = frame-iframe;
    elseif(frame>fframe)
        pos = count-1;
    end
    tmp_transf = convertpath2lnx(fullfile(transf_folder,['MAT_' sprintf('%04d',pos)]));
    
    % Applying transf to tmp
    cmdprfx = get_fsl_command('flirt');
    cmd2execute = convertcmd2lnx([cmdprfx ' -in ' tmp ' -ref ' REF ' -out ' tmp_MoCo ' -applyxfm -init ' tmp_transf ' -interp spline -datatype float ']);
    system(cmd2execute);
    
    % Clean Up
    delete([tmp '.nii.gz'])    
end
fprintf(1,'done. ');

fprintf(1,'\n Merging motion corrected frames ');
file_list              = dir(fullfile(singleMoCo_folder,[fname '_*']));
motion_corrected_name  = convertpath2lnx(fullfile(inpath,[fname '_MoCo.nii.gz']));
cmdprfx = get_fsl_command('fslmerge');
cmd2execute = [cmdprfx ' -t ' motion_corrected_name ' '];
for jj = 1 : length(file_list)
    cmd2execute = [ cmd2execute ' ' convertpath2lnx(fullfile(singleMoCo_folder,file_list(jj).name)) ];
end
cmd2execute = convertcmd2lnx(cmd2execute);
system(cmd2execute);
fprintf(1,'done. ');



    




