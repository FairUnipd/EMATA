function outfile = motion_correction_fsl(infile, output_path, tgframe, iframe, fframe)

[~, fname, ext]  = fileparts(infile);
copyfile(infile,fullfile(output_path, [fname ext]));

infile = fullfile(output_path,[fname ext]);

% realign
outfile = FSL_MoCo_batch(infile,tgframe,iframe,fframe);

%system(['rm ' infile ])

end

