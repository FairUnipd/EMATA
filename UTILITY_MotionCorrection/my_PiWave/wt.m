function y=wt(x,h,g,scales,del1,del2)
% WT   Discrete Wavelet Transform.
% 
%      WT(X,H,G,SCALES) calculates the wavelet transform of vector X.  If X
%      is a matrix (2D), WT will calculate the one dimensional wavelet
%      transform of each row vector. The second argument H is the lowpass
%      filter and the third argument G the highpass filter.
%
%      The output vector contains the coefficients of the DWT ordered from
%      the low pass residue at scale SCALES to the coefficients at the
%      lowest scale, as the following example ilustrates:
%
%      Output vector (k=3):
%
%      [------|------|------------|------------------------]
%	  |	  |	   |		    |
%	  |	  |	   |		    `-> 1st scale coefficients 
% 	  |	  |	   `-----------> 2nd scale coefficients
%	  |	  `--------------------> 3rd scale coefficients
%	  `----------------> Low pass residue  at 3rd scale 
%
%       
%      If X is a matrix, the result will be another matrix with 
%      the same number of rows, holding each one its respective 
%      transformation.
%
%      WT (X,H,G,SCALES,DEL1,DEL2) calculates the wavelet transform of
%      vector X, but also allows the user to change the alignment of the
%      outputs with respect to the input signal. This effect is achieved by
%      setting to DEL1 and DEL2 the delays of H and G respectively. The
%      default values of DEL1 and DEL2 are calculated using the function
%      WTCENTER.
%
% This function is a wrapper for wtnd, for compatibility with UviWave. See
% below for UviWave copyright.
%
% See also:  WTND, IWT, IWTND, WTCENTER, ISPLIT.
%
% $Id: wt.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

%--------------------------------------------------------
% Copyright (C) 1994, 1995, 1996, by Universidad de Vigo 
%                                                      
%                                                      
% Uvi_Wave is free software; you can redistribute it and/or modify it      
% under the terms of the GNU General Public License as published by the    
% Free Software Foundation; either version 2, or (at your option) any      
% later version.                                                           
%                                                                          
% Uvi_Wave is distributed in the hope that it will be useful, but WITHOUT  
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or    
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License    
% for more details.                                                        
%                                                                          
% You should have received a copy of the GNU General Public License        
% along with Uvi_Wave; see the file COPYING.  If not, write to the Free    
% Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.             
%                                                                          
%      Authors: Sergio J. Garcia Galan 
%               Cristina Sanchez Cabanelas 
%       e-mail: Uvi_Wave@tsc.uvigo.es
%--------------------------------------------------------

if nargin < 3
  error('Need data to transform and two filters');
end
if nargin < 4
  scales = [];
end
if nargin < 5
  del1 = [];
end
if nargin < 6
  del2 = [];
end

sz = size(x);
n_dims = length(sz);
p_dims = zeros(1, n_dims);
if sz(2) > 1
  p_dims(2) = 1;
else 
  p_dims(1) = 1; 
end
  
if n_dims > 2
  warning('wt does a 1D transform; use wtnd for N-D transforms');
end
y = wtnd(x, h, g, scales, del1, del2, p_dims);