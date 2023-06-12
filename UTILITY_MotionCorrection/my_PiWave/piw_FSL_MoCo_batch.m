function motion_corrected_name = piw_FSL_MoCo_batch(filename,tgframe,iframe,fframe)

%%

levels=2;


% modificato Erica Silvestri Feb 2019 (realign to first image: tgframe, using FSL's mcflirt)
% modificato Matteo Tonietto Dic 2013 (usa nii)

%  piw_coreg 
%			frame by frame co-registration using "spm" procedures
%						
%  usage:       	piw_coreg
%	The program writes the filtered image with the same name + extension 'wave_movcor'
%   The proper spm path (spm2 or spm5) must be in Matlab
%=======================================================================
%				-file input
%=======================================================================
% [file, pathname]   	= uigetfile('*.*','Please select reference image',200,300);
% if file==0,,
%    uiwait(msgbox('No file selected. Returning to Menu','Piwave Error','modal')); 
%    close all
%    piwave('onon');
%    return
% end
% 
% filename 		= [pathname file];
% cd(pathname)
% 
% [file, pathname]   	= uigetfile('*.*','Please select image to correct',200,300);
% if file==0,,
%    uiwait(msgbox('No file selected. Returning to Menu','Piwave Error','modal')); 
%    close all
%    piwave('onon');
%    return
% end
% 
% filenamec 		= [pathname file];
% cd(pathname)
%=======================================================================
%				-Input of Filter Levels
%=======================================================================
% levels    = menu('Please, select filter type','1/64 Battle Lemarie','2/64 Battle Lemarie');
% drawnow 
%=======================================================================
%				-setting wavelet parameters
%=======================================================================

fprintf(1,' \n   Reading Volume ...');
DYN = load_untouch_nii(filename);
DYN = double(DYN.img);
fprintf(1,' done.');

[inpath, fname, ~]  = fileparts(filename);
[~, fname, ~]      = fileparts(fname);

DIM             = size(DYN);
%=======================================================================
%				-Input target frame
%=======================================================================
% str    = [' {' num2str(1) '-' num2str(DIM(4)) '}:'];
% tgframe= str2double(inputdlg(['Type in reference frame' str], 'PIwave Input'));
% if ~(tgframe<=DIM(4)& tgframe>=1),
%     tgframe = round(DIM(4)/2);
% end
% drawnow
%=======================================================================
%				-Input initial frame
%=======================================================================
% iframe= str2double(inputdlg(['Type in initial frame' str], 'PIwave Input'));
% if ~(iframe<=DIM(4)& iframe>=1),
%     iframe = 1;
% end
% drawnow
%=======================================================================
%				-Input final frame
%=======================================================================
% fframe= str2double(inputdlg(['Type in final frame' str], 'PIwave Input'));
% if ~(fframe<=DIM(4)& fframe>=1),
%     fframe = DIM(4);
% end
% drawnow


%=======================================================================
%				-setting wavelet parameters
%=======================================================================
dimxy	= max([DIM(1) DIM(2)]);
for k=1:8
    if(2^k>=dimxy)break;end;
end
sizexy	= 2^k;
	
for k=1:8
    if(2^k-20>=DIM(3))break;end;
end
sizez	= 2^k;

c1	= sizexy/2;
c2	= sizez/2;
	
	
if((DIM(3)/2-floor(DIM(3)/2))~=0)
  indexz	= c2 - floor(DIM(3)/2)+1;
else
   indexz	= c2 - (DIM(3)/2);
end 

[H,K,RH,RK]		= lemarie(sizez/2);
	
%=======================================================================
%				-transforming cycle
%=======================================================================
fprintf(1,'\n Wavelet Filtering ...');
count	= 0;
%	Transforming Cycle
for 	f=iframe:fframe
	    fprintf(1,'\n   Volume no. %d',f);
        T       = DYN(:,:,:,f);
    	F		= zeros(DIM(1),DIM(2),DIM(3));
    	F(:)	= T(:);
    	clear 	T
		
    	%	Putting into an adequate frame of dyadic dimensions
    	frame		= zeros(sizexy,sizexy,sizez);
    	frame(:,:,indexz:indexz+DIM(3)-1)	= F;
    	clear F
    		
    	%	3-dimensional wavelet transform
    	str		= ['\n   Transforming and denoising'];
    	fprintf(1,str);
    	w	= wtnd(frame,H,K,levels);
    	
    	%	Zeroing detail coefficients
    	w(sizexy/2+1:sizexy, 1:sizexy/2       , 1:sizez/2)	= 0;
    	w(1:sizexy/2   	   , sizexy/2+1:sizexy, 1:sizez/2)	= 0;
    	w(sizexy/2+1:sizexy, sizexy/2+1:sizexy, 1:sizez/2)	= 0;
    	w(1:sizexy/2       , 1:sizexy/2       , sizez/2+1:sizez)= 0;
    	w(sizexy/2+1:sizexy, 1:sizexy/2       , sizez/2+1:sizez)= 0;
    	w(1:sizexy/2       , sizexy/2+1:sizexy, sizez/2+1:sizez)= 0;
    	w(sizexy/2+1:sizexy, sizexy/2+1:sizexy, sizez/2+1:sizez)= 0;
    	
        if (levels==2)
            %	Zeroing 2nd level coefficients
    	    w(sizexy/4+1:sizexy/2, 1:sizexy/4         , 1:sizez/4)	= 0;
    	    w(1:sizexy/4   	     , sizexy/4+1:sizexy/2, 1:sizez/4)	= 0;
    	    w(sizexy/4+1:sizexy/2, sizexy/4+1:sizexy/2, 1:sizez/4)	= 0;
    	    w(1:sizexy/4         , 1:sizexy/4         , sizez/4+1:sizez/2)= 0;
    	    w(sizexy/4+1:sizexy/2, 1:sizexy/4         , sizez/4+1:sizez/2)= 0;
    	    w(1:sizexy/4         , sizexy/4+1:sizexy/2, sizez/4+1:sizez/2)= 0;
    	    w(sizexy/4+1:sizexy/2, sizexy/4+1:sizexy/2, sizez/4+1:sizez/2)= 0;
        end
        
    	img		= iwtnd(w ,RH,RK,levels);
    	I		= img(:,:,indexz:indexz+DIM(3)-1);
    	count		= count+1;
    	DYN(:,:,:,count)	= I;
    	clear frame    		    		
end

%%

%=======================================================================
%				-re-alligning the wavelet filtered image
%=======================================================================

IN                  = convertpath2lnx(fullfile(inpath,'temp.nii.gz'));
REF                 = convertpath2lnx(fullfile(inpath,'REF.nii.gz'));
OUT                 = convertpath2lnx(fullfile(inpath,'temp_MoCo'));
transf_folder       = convertpath2lnx(fullfile(inpath,'temp_MoCo.mat'));
singleMoCo_folder   = convertpath2lnx(fullfile(inpath,[fname '_MoCo_single']));

imgs_2_write        = DYN(:,:,:,1:count);
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

% 
% 
% system(convertcmd2lnx(['rm -R ' singleMoCo_folder]));
% system(convertcmd2lnx(['rm ' IN]));
% system(convertcmd2lnx(['rm ' OUT '.nii.gz']));
% system(convertcmd2lnx(['mv '    OUT '.par '  fullfile(inpath,'moco_params.par') ]));
% system(convertcmd2lnx(['mv '    OUT '.mat '  fullfile(inpath,'moco_params.mat') ]));


    





