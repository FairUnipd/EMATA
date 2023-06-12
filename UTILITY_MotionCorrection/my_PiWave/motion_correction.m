function outfile = motion_correction(infile, output_path, tgframe, iframe, fframe)

[~, fname, ext]  = fileparts(infile);
copyfile(infile,fullfile(output_path, [fname ext]));

infile = fullfile(output_path,[fname ext]);

% realign
outfile = piw_FSL_MoCo_batch(infile,tgframe,iframe,fframe);

system(['rm ' infile ])

end

