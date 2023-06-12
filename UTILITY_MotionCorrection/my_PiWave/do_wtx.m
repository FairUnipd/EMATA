function t = do_wtx(t, h, g, dlp, dhp)
% do first scale wavelet transform in x dimension of matrix   
% FORMAT t = do_iwtx(t, h, g, dlp, dhp) 
%  
% Calculates the first-scale 1D wavelet transform along the X dimension of
% matrix t. The second argument rh is the analysis lowpass filter and the
% third argument rh is the analysis highpass filter.
%  
% dlp, dhp are the delays for the low-pass and high-pass filters.
%
% $Id: do_wtx.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

%-This is the help file for the compiled routine
error('do_wtx.c not compiled - see phiwave(''make'')')
