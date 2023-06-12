function [y, scales] = wtnd(x, h, g, scales, del1, del2, p_dims)
% wtnd - Discrete N-D Wavelet Transform.
% 
% WTND(X,H,G,SCALES) calculates the N-D wavelet transform of matrix X,
% where N is the number of dimensions of X.  The second argument H is the
% lowpass filter and the third argument G the highpass filter.  WTND
% generalizes the algorithm for UviWave WT to N dimensions.
%
% For a vector, the output contains the coefficients of the DWT ordered from
% the low pass residue at SCALE to the coefficients at the lowest scale, as
% the following example ilustrates:
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
% A matrix can be transformed over more than one dimension. For a 2D matrix,
% the output would look like this: for every scale, the lowpass residue is
% placed at the top-left corner of the corresponding subimage, the
% horizontal high frequency band at the top-right, the vertical high
% frequency band at the bottom-left and the diagonal high frequency band at
% the bottom-right. Every successive wavelet subimage substitutes the
% residue of the previous scale.
%	
%		Example with 2 scales:
%					 _______
%	2nd scale substituting the  -->	|_|_|   | <-- 1st scale 
%	first scale lowpass residue	|_|_|___|     horiz. detail	
%					|   |   | 
%		        1st scale ---->	|___|___| <-- 1st scale 
%		      vertical detail		    diagonal detail
%
% Notes 1: Dimensions to transform
% --------------------------------
%
% If the passed matrix X has N dimensions, then the default behaviour is to
% transform all N dimensions.  It is possible to select a subset of
% dimensions to transform, using the P_DIMS input (see below).  For example
% we could choose to do a 2D transform on a 3D matrix.
% 
% WTND(X,H,G,SCALES,DEL1,DEL2) calculates the N-D wavelet
% transform of matrix X, but also allows the user to change the alignment of
% the outputs with respect to the input signal. This effect is achieved by
% setting to DEL1 and DEL2 the delays of H and G respectively. The default
% values of DEL1 and DEL2 are calculated using the function WTCENTER.
%
% Note 2: Using P_DIMS
% --------------------
% 
% WTND(X,H,G,SCALES,DEL1,DEL2,P_DIMS) adds the ability to wt over a subset
% of the matrix dimensions.  P_DIMS should be a vector of flag values, one
% value per dimension of X; each dimension with a flag value of 1 is wt'ed,
% dimensions of size 1 or with a 0 flag value are ignored. Thus, if we have
% a 3D matrix, the default value for P_DIMS will be [1 1 1]; if you want to
% transform just over the rows of this matrix, you could override the
% default by passing a value of P_DIMS of [0 1 0];  P_DIMS can also be a
% scalar, in which case it specifies that the first P_DIMS dimensions
% should be processed; for example, for a 3D matrix, a P_DIMS value of 2
% will expand to a P_DIMS vector of [1 1 0].
% 
% Note 3: Different dimensions, different filters
% -----------------------------------------------
%
% Each dimension can have its own wavelet filter; the input filters h and
% g can be given as cell arrays, each cell containing a filter for the
% matching processed dimension. For example, let use imagine you are passing
% a 3D matrix, but only want to transform the first 2 dimensions.  You want
% a different filter for the first and second dimensions.  You would use a
% P_DIMS of [1 1 0] (see above), and pass a two element cell array in h and
% in g, with the h filter for dimension 2 in h{2}, etc.  Similarly the
% delays DEL1 and DEL2 can be vectors, with one delay for each processed
% dimension.
%
% Returns
% Y           - transformed matrix
% SCALES      - number of scales transformed
%               (SCALES can be set in routine if not passed as input)
% 
%      See also:  IWT, WT2D, IWT2D, WTCENTER, ISPLIT.
%
% Based on wt.m from UviWave 3.0, with thanks - see below
%
% $Id: wtnd.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

%--------------------------------------------------------
% wt is Copyright (C) 1994, 1995, 1996, by Universidad de Vigo 
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

% Programmers' notes
% 
% We do the wt by iteratively switching the matrix dimension we want to
% process to be the first dimension (columns), then filtering. The algorithm
% goes up to 4D, but could be extended further by adding the relevant lines
% to the switch statements, or made general by using subsref commands:
% [n_dims = 2; d = subsref(c, struct('type', '()', 'subs', repmat({:}, 1,
% n_dims)))]; I haven't used the subsref commands here because they can be
% considerably slower than direct [c(:,:)] type referencing
  
% -----------------------------------
%    CHECK PARAMETERS AND OPTIONS
% -----------------------------------

if nargin < 3
  error('Need at least matrix to wt, and wt filters');
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
if xor(isempty(del1), isempty(del2))
  error('You cannot specify only one of the two delays'); 
end
if nargin < 7
  p_dims = [];
end

% ------------------------
% Process input parameters
% ------------------------

% Input image dimensions
sz     = size(x);
n_dims = length(sz);

% Process p_dims 
p_d_l = prod(size(p_dims));
if p_d_l == 0  % empty
  p_dims = ones(1, n_dims);
elseif p_d_l == 1
  p_dims = [ones(1, p_dims) zeros(1, n_dims-p_dims)];
elseif p_d_l < n_dims
  p_dims = [p_dims(:)' ones(1, n_dims-p_d_l)];
elseif p_d_l > n_dims
  error('p_dims array has too many values for passed matrix');
end
p_dims = p_dims & sz > 1;
if ~any(p_dims), y = x;  return, end
n_p_dims = sum(p_dims);

% make filters into cells, and expand to N-D if necessary
if ~iscell(h), h = {h}; end
if prod(size(h))==1, h = repmat(h, 1, n_p_dims); end
if ~iscell(g), g = {g}; end
if prod(size(g))==1, g = repmat(g, 1, n_p_dims); end

%--------------------------
%    DELAY CALCULATION 
%--------------------------

if isempty(del1)
  % Calculate delays as the C.O.E. of the filters
  for d = 1:n_p_dims
    dlp(d) = wtcenter( h{d} );
    dhp(d) = wtcenter( g{d} );
  end
  % difference between them must be even
  dhp = dhp + (rem(dhp-dlp,2)~=0);	
else
  % Other experimental filter delays can be forced from the arguments
  o = ones(1, n_p_dims);
  dlp=del1; if prod(size(dlp))==1, dlp = o * dlp; end
  dhp=del2; if prod(size(dhp))==1, dhp = o * dhp; end
end

% get output and scales dimensions 
[wt_sz sc_in_sz sc_out_sz scales] = wt_dims(sz, scales, p_dims);

% Offsets
offsets = wt_sz - sz;

%------------------------------
%     START THE ALGORITHM 
%------------------------------

% For doing tricksy permute thing in loop below (see help wt_dim_shifts)
[shifts end_shift] = wt_dim_shifts(p_dims, sz);
dims = [1:n_dims]';

% t is the input matrix to be wt'ed
t = x;

% y is the output matrix
y = zeros(wt_sz(:)');

% For every scale (iteration)...
for sc=1:scales			
  % get new data block
  in_sz = sc_in_sz(sc, :);
  if sc > 1
    % following assumes UviWave ordering
    switch n_dims
     case 2
      t = t(1:in_sz(1), 1:in_sz(2));
     case 3
      t = t(1:in_sz(1), 1:in_sz(2), 1:in_sz(3));
     case 4
      t = t(1:in_sz(1), 1:in_sz(2), 1:in_sz(3), 1:in_sz(4));
     otherwise
      error('Not implemented - but go ahead and do it if you need it');
    end
  end
  
  for d = 1:n_p_dims

    % move next dimension to column dimension
    s = shifts(d);
    if s, t = permute(t, circshift(dims, s)); end
    
    % all the hard work is in C
    t = do_wtx(t, h{d}, g{d}, dlp(d), dhp(d));
    
  end

  % and back to original shape
  if end_shift
    t = permute(t, circshift(dims, end_shift));
  end
  
  % reset offsets
  out_sz = sc_out_sz(sc, :);
  offsets = offsets - (out_sz - in_sz);
  op1 = offsets + 1;
  
  % set data block into output
  % following assumes UviWave ordering
  if sc == 1 & ~any(offsets)  % for speed, do the simplest case 
    y = t;
  else
    switch n_dims
     case 2
      y(op1(1):out_sz(1) + offsets(1), ...
	op1(2):out_sz(2) + offsets(2)) = t;
     case 3
      y(op1(1):out_sz(1) + offsets(1), ...
	op1(2):out_sz(2) + offsets(2), ...
	op1(3):out_sz(3) + offsets(3)) = t;
     case 4
      y(op1(1):out_sz(1) + offsets(1), ...
	op1(2):out_sz(2) + offsets(2), ...
	op1(3):out_sz(3) + offsets(3), ...
	op1(4):out_sz(4) + offsets(4)) = t;
     otherwise
      error('Not implemented');
    end    
  end
end

%------------------------------
%    END OF THE ALGORITHM 
%------------------------------

