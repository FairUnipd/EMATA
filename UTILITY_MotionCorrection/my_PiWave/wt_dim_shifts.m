function [shifts, end_shift] = wt_dim_shifts(p_dims, sz)
% return dimension permute shifts needed for wt/iwt routines
% FORMAT [shifts, end_shift] = wt_dim_shifts(p_dims)
% 
% Inputs
% 
% p_dims      - flags, one for each dimension, non-zero if dimension is
%               to be (wt, iwt) processed
% sz          - size of matrix to be processed
%               (needed to identify row vectors)
% 
% Outputs 
% 
% shifts      - values, one for each non-zero value of p_dims, giving how
%               many extra dimensions to shift to get the current (p_dim)
%               dimension to be X (columns)
%   
% end_shift   - how many shifts right to get from last processed
%               dimension back to original matrix orientation
%
% For example, if processing all 3 dimensions of a 3D matrix, we will need
% to specify 4 shifts.  When processing the first (X) dimension, we do not
% have to do a shift (shift(1) = 0).  For Y we will need to shift Y to X
% (shift(2) = -1).  For Z, we further need to shift Z to X: shift(3) = -1;
% Last, to shift back to where we started (X back to X) we need an end shift
% (end_shift = -1).  This will result in the following permutes, in the
% wt/iwt routines:
% 
% x1 = permute(x,  [1 2 3]);  % shift(1) of 0 
% x2 = permute(x1, [2 3 1]);  % Y->X; shift(2) of -1
% x3 = permute(x2, [2 3 1]);  % Z->X; shift(3) of -1
% x  = permute(x3, [2 3 1]);  % X->X; end_shift of -1
% 
% $Id: wt_dim_shifts.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $ 

n_dims = length(p_dims);
fpd  = find(p_dims);

% First check for situations where we do not have to do any shifts
if all(fpd == 1) | ...           % only processing X dimension
  (n_dims == 2 & sz(1) == 1)     % row vector
  shifts =  zeros(1, sum(p_dims));
  end_shift = 0;
else  % we do have to do shifts
  shifts = diff([1 fpd n_dims+1]) * -1;
  end_shift = shifts(end);
  shifts = shifts(1:n_dims);
end

