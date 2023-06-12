function t = do_iwtx(t, rh, rg, dlp, dhp, reco_detail, truncate) 
% do first scale inverse wavelet transform in x dimension of matrix   
% FORMAT t = do_iwtx(t, rh, rg, dlp, dhp, reco_detail, truncate) 
%  
% Calculates the first-scale 1D inverse wavelet transform along the X (row)
% dimension of matrix t, which should be a wavelet transformed matrix. The
% second argument rh is the synthesis lowpass filter and the third argument
% rh is the synthesis highpass filter.
%  
% dlp, dhp are the delays for the low-pass and high-pass filters.
% 
% reco_detail are optional arguments, and default to 1 and 0 respectively
% reco_detail is a flag; if zero, detail is not reconstructed into signal
% truncate is a flag; if not zero, the last value in the x dimension is
% discarded, and a new matrix returned of size N-1 in X, where N was the
% original number of rows.
%
% $Id: do_iwtx.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

%-This is the help file for the compiled routine
error('do_iwtx.c not compiled - try phiwave(''make'')')
