function y = iwtnd(wx, rh, rg, scales, o_sz, sc_levels, del1, del2, p_dims) 
% MATRIX_IWT Discrete Inverse N-D Wavelet Transform.
%
% IWTND(WX,RH,RG,SCALES) calculates the N-D inverse wavelet transform of
% vector WX, which should be a SCALES-scales direct wavelet transform. By
% default, N, the number of dimensions to transform is the same as the
% number of the dimensions of the input WX.  The second argument RH is the
% synthesis lowpass filter and the third argument RG the synthesis highpass
% filter.
%
% Notes 1: Dimensions to transform
% --------------------------------
%
% If the passed matrix WX has N dimensions, then the default behaviour is to
% transform all N dimensions.  It is possible to select a subset of
% dimensions to transform, using the P_DIMS input (see below).  For example
% we could choose to do a 2D transform on a 3D matrix.
% 
% Notes 2: Output dimensions from the iwt
% --------------------------------------- 
%
% The original wavelet transform may have added rows columns etc to the
% output, because it needed dimensions divisible by 2 to do the
% transform. In doing the inverse transform, we need to know or work out
% what the original dimensions were. IWTND will calculate the size of the
% reconstructed matrix dimensions to be as large as possible (maybe 1 point
% larger than the original) unless the size is given using
% IWTND(WX,RH,RG,SCALES,SIZ). A value of 0 for SIZ is the same as omitting
% it.  SIZ should either be scalar, in which case it it the default size for
% any reconstructed dimension, or should be a vector with the same number of
% values as reconstructed dimensions (see above, and P_DIM); each value
% specifies an output dimension size.
% 
% Note that iwtnd differs a little from UviWave iwt2d in its understanding
% of dimensions.  For iwtnd, the first value in the SIZ vector refers to the
% number of rows (M) and the second value refers to the number of columns
% (N).  UviWave iwt2d (see help iwt2d) takes the first passed size (SIZX) as
% the width (number of columns N) and the second passed size (SIZY) as the
% height (number of rows, M).  In this sense iwtnd follows the matlab
% convention (number of rows first, then number of columns).
% 
% IWTND can be used to perform a single process of multiresolution
% analysis. The way to do it is by selecting the scales whose highpass bands
% (detail signals) should be ignored for reconstruction.
%
% This can be done Using IWTND(WX,RH,RG,SCALES,SIZ,SC_LEVELS) where
% SC_LEVELS is a SCALES-sized vector,1's or 0's. An i-th coefficient of 0
% means that the i-th scale detail (starting from the deepest) should be
% ignored. SC_LEVELS vector can be replaced by a single number for selecting
% just only the SC_LEVELS deepest scales.
%
% An all-ones vector, or an empty values, or a single number equal to
% SCALES, is the same as the normal inverse transform.
%         
% IWTND(WX,RH,RG,SCALES,SIZ,SC_LEVELS,DEL1,DEL2) calculates the inverse
% transform or performs the multiresolution analysis, but allowing the user
% to change the alignment of the outputs with respect to the input
% signal. This effect is achieved by setting to DEL1 and DEL2 the analysis
% delays of H and G respectively, and calculating the complementary delays
% for synthesis filters RH and RG. The default values of DEL1 and DEL2 are
% calculated using the function WTCENTER.
%
% Note 3: Using P_DIMS
% --------------------
% 
% IWTND(WX,RH,RG,SCALES,SIZ,SC_LEVELS,DEL1,DEL2,P_DIMS) adds the ability to
% iwt over a subset of the matrix dimensions.  P_DIMS should be a matrix of
% flag values, one value per dimension of X; each dimension with a flag
% value of 1 is iwt'ed, dimensions of size 1 or with a 0 flag value are
% ignored.  Thus, if we have a 3D matrix, the default value for P_DIMS will
% be [1 1 1]; if you want to transform just over the rows of this matrix,
% you could override the default by passing a value of P_DIMS of [0 1 0].
% P_DIMS can also be a scalar, in which case it specifies that the first
% P_DIMS dimensions should be processed; for example, for a 3D matrix, a
% P_DIMS value of 2 will expand to a P_DIMS vector of [1 1 0].
%
% Note 4: Different dimensions, different filters
% -----------------------------------------------
%
% Each dimension can have its own wavelet filter; the input filters rh and
% rg can be given as cell arrays, each cell containing a filter for the
% matching processed dimension. For example, let use imagine you are passing
% a 3D matrix, but only want to transform the first 2 dimensions.  You want
% a different filter for the first and second dimensions.  You would use a
% P_DIMS of [1 1 0] (see above), and pass a two element cell array in h and
% in g, with the rh filter for dimension 2 in h{2}, etc.  Similarly the
% delays DEL1 and DEL2 can be vectors, with one delay for each processed
% dimension.
%
% See also: WT, WTND, WTCENTER, WTMETHOD
%
% Based on iwt.m from UviWave 3.0, with thanks - see below
%
% $Id: iwtnd.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

% Restrictions:
%
% - Synthesis filters from the same set as in analysis must be used.  If
% forced delays were used in analysis, the same delays should be forced in
% synthesis (iwtnd calculates the complementary ones), so as to get a
% perfect vector reconstruction (or the equivalent in the case of not full
% reconstruction).
%
% - The number of scales indicated in SCALES, must match the number of
% scales specified in the analysis process. Otherwise, the reconstruction
% will be completely incorrect. The same applies to the original vector size
% SIZ, but if it's not given, or it's set to zero, IWTND will give the
% reconstructed vector the largest size possible.

%--------------------------------------------------------
% iwt: Copyright (C) 1994, 1995, 1996, by Universidad de Vigo
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

% -----------------------------------
%    CHECK PARAMETERS AND OPTIONS
% -----------------------------------

if nargin < 4
  error('Need at least matrix to iwt, iwt filters and scales');
end
if nargin < 5
  o_sz = [];
end
if nargin < 6, 	
  sc_levels=[];
end;
if nargin < 7
  del1 = [];
end
if nargin < 8
  del2 = [];
end
if xor(isempty(del1), isempty(del2))
  error('You cannot specify only one of the two delays'); 
end
if nargin < 9
  p_dims = [];
end  
  
% Process scales levels: if SC_LEVELS specifies the number of scales then
% build the SC_LEVELS vector with SC_LEVELS ones and SCALES-SC_LEVELS zeros.
sc_l_l = prod(size(sc_levels));
if sc_l_l == 0  % empty
  % SC_LEVELS not given means reconstructing all bands.
  sc_levels=ones(1, scales);
elseif sc_l_l == 1
  sc_levels=[ones(1, sc_levels) ...
	     zeros(1, scales - sc_levels)];
elseif sc_l_l ~= scales
  error(['SC_LEVELS should be a single number (<=SCALES) ' ...
	 'or a vector with SCALES elements']);
else  
  % And make sure that all nonzero elements in SC_LEVELS are ones
  sc_levels(sc_levels~=0) = 1;
end

% input dimensions
sz     = size(wx);
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
if ~any(p_dims), y = wx;  return, end
n_p_dims = sum(p_dims);

% make filters into cells, and expand to N-D if necessary
if ~iscell(rh), rh = {rh}; end
if prod(size(rh))==1, rh = repmat(rh, 1, n_p_dims); end
if ~iscell(rg), rg = {rg}; end
if prod(size(rg))==1, rg = repmat(rg, 1, n_p_dims); end

% ----------------------------------
%    CHECK THE ORIGINAL LENGTH
% ----------------------------------

% Process input sizes
def_o_sz = zeros(1, n_dims);
def_o_sz(~p_dims) = sz(~p_dims);
switch prod(size(o_sz));
 case 0 % empty
  o_sz = def_o_sz;
 case {1, n_p_dims} 
  def_o_sz(p_dims) = o_sz(:)';
  o_sz = def_o_sz;
 case  n_dims
  % Dimensions to be transformed will not change
  tmp = ~p_dims & o_sz==0;
  o_sz(tmp) = sz(tmp);
  if any(o_sz(~p_dims) ~= sz(~p_dims))
    error('Dimensions not being transformed should not change size');
  end
otherwise
 error(['Original size vector should have one element for each ' ...
	 'dimension of the input matrix, or one element for each '...
	'processed dimension, or be a scalar']);
end

% Get maximum size for any missing input sizes
missing_dims = (o_sz == 0);
for d = find(o_sz==0)
  o_sz(d) = maxrsize(sz(d), scales);
end
if any(o_sz == 0)
  error(sprintf(['Can''t determine the original length for' ...
		 'dimension %d; SCALES might be wrong\n'], ...
		find(o_sz == 0)));
end

% Estimated input / output sizes for current original sizes
[wt_sz sc_o_sz sc_wt_sz] = wt_dims(o_sz, scales, p_dims);

% Check as yet unchecked dims to see if they work
dims_to_check = p_dims & ~missing_dims;
dims_to_redo = find(wt_sz(dims_to_check) ~= sz(dims_to_check));
if ~isempty(dims_to_redo)
  for r = 1:length(dims_to_redo)
    new_o_sz(r) = maxrsize(sz(dims_to_redo(r)), scales);
  end
  fprintf('Size %d for dim %d is not correct, trying default %d: \n', ...
	  [o_sz(dims_to_redo); dims_to_redo; new_o_sz]);
  if any(new_o_sz == 0)
    error(sprintf(['No default size found for dim %d. ' ...
		   'SCALES might be wrong\n'], ...
		  dims_to_redo(new_o_sz==0))); 
  end
  o_sz(dims_to_redo) = new_o_sz;
  [wt_sz sc_o_sz sc_wt_sz] = wt_dims(o_sz, scales, p_dims);
  
  wrong_sz = wt_sz ~= sz;
  if any(wrong_sz)
    error(sprintf(['Default failed for dim %d. ' ...
		   'SCALES might be wrong\n'], ...
		  find(wrong_sz)));
  end
  fprintf(['(Check the resulting size(s); may be wrong. ' ...
	   'If so, check SCALES)\n']);
end

%--------------------------
%    DELAY CALCULATION 
%--------------------------

for d = 1:n_p_dims
  llp(d) = length(rh{d});	% Length of the lowpass filters.
  lhp(d) = length(rg{d});	% Length of the highpass filters.
end

% The total delay of the analysis-synthesis process must match the sum of
% the analysis delay plus the synthesis delay. SUML holds this total delay,
% which is different depending on the kind of filters.
suml = llp+lhp-2;		
difl = abs(lhp-llp);		
tmp = rem(difl,2)==0;		
suml(tmp) = suml(tmp)/2;		

if isempty(del1)
  % Calculate analysis delays as the reciprocal M. C.
  for d = 1:n_p_dims
    dlpa(d) = wtcenter( rg{d} );
    dhpa(d) = wtcenter( rh{d} );
  end
  % difference between them must be even
  dhpa = dhpa + (rem(dhpa-dlpa,2)~=0);	
else
  % Other experimental filter delays can be forced from the arguments
  o = ones(1, n_p_dims);
  dlpa=del1; if prod(size(dlpa))==1, dlpa = o * dlpa; end
  dhpa=del2; if prod(size(dhpa))==1, dhpa = o * dhpa; end
end

% Synthesis delays are the total minus the analysis delays.
dlp = suml - dlpa;		
dhp = suml - dhpa;
							
%------------------------------
%     START THE ALGORITHM 
%------------------------------

% For doing tricksy permute thing in loop below (see help wt_dim_shifts)
[shifts end_shift] = wt_dim_shifts(p_dims, sz);
dims = [1:n_dims]';

% upend scale size matrix, scales has opposite meaning compared to wt
sc_wt_sz = flipud(sc_wt_sz);

% Flags for truncation (scales by dims)
truncations = sc_wt_sz - flipud(sc_o_sz);

% offsets caused by extra 0's put in by wt
offsets = zeros(1, n_dims);

for sc=1:scales

  % get new data block containing lowpass + highpass bits of vector
  % following assumes UviWave ordering
  
  % do simplest case simply for speed
  if sc==scales & ~any(offsets)
    t = wx; 
  else % general case
    in_sz = sc_wt_sz(sc,:);
    op1 = offsets + 1;
    switch n_dims
     case 2
      t = wx(op1(1):in_sz(1)+offsets(1), ...
	     op1(2):in_sz(2)+offsets(2));
     case 3
      t = wx(op1(1):in_sz(1)+offsets(1), ...
	     op1(2):in_sz(2)+offsets(2), ...
	     op1(3):in_sz(3)+offsets(3));
     case 4
      t = wx(op1(1):in_sz(1)+offsets(1), ...
	     op1(2):in_sz(2)+offsets(2), ...
	     op1(3):in_sz(3)+offsets(3), ...
	     op1(4):in_sz(4)+offsets(4));
     otherwise
      error('Not implemented');
    end
  end
  
  % if available put the result from the last pass into data block
  if sc > 1
    t_sz = size(last_t);
    switch n_dims
     case 2
      t(1:t_sz(1), 1:t_sz(2)) = last_t;
     case 3
      t(1:t_sz(1), 1:t_sz(2), 1:t_sz(3)) = last_t;
     case 4
      t(1:t_sz(1), 1:t_sz(2), 1:t_sz(3), 1:t_sz(4)) = last_t;
     otherwise
      error('Not implemented');
    end    
  end

  p_truncs = truncations(sc, p_dims);
  
  for d = 1:n_p_dims
    
    % move next dimension to X (columns)
    s = shifts(d);
    if s, t = permute(t, circshift(dims, s)); end
    
    % hard work is in C
    t = do_iwtx(t, rh{d}, rg{d}, dlp(d), dhp(d), ...
		sc_levels(sc), ...
		p_truncs(d));
        
  end % for dim 
  
  % and back to original shape
  if end_shift
    t = permute(t, circshift(dims, end_shift));
  end

  % set up for next pass
  offsets = offsets + truncations(sc, :);
  last_t = t;
  
end % for scale

y = t;

%------------------------------
%    END OF THE ALGORITHM 
%------------------------------

