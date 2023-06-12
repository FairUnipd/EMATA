function [wt_sz, sc_in_sz, sc_out_sz, scales] = wt_dims(sz, scales, p_dims) 
% returns output size and sizes of scales for matrix to be wt'ed 
% FORMAT [wt_sz, sc_in_sz, sc_out_sz, scales] = wt_dims(dims, scales, p_dims)
% 
% Inputs 
% sz                  - current matrix size (1 by ndims) (dimensions size 1 are
%                       ignored) 
% scales              - number of scales for wt (defaults to max)
% p_dims              - optional flags specifying dimensions to transform
% 
% Outputs 
% wt_sz               - expected size (1 by ndims) after wt 
%
% sc_in_sz        - size of each block of data (one pre scale) to be entered
%                       into wt (scales by ndims)
% sc_out_sz       - size of each block (one per scale) as output from wt
%                       (scales by ndims) 
% scales              - number of scales for wt (will have been calculated
%                       if empty on input)
%
% The problem is that the wt fpr one scale and one dimension may generate a
% matrix that is larger by 1 in the transformed dimension, because the wt
% will generate a padding 0 at the end before doing the wt, so that the
% ouputs can be decimated.  So we need to be able to predict the various
% sizes as we go through the wt, in order to get and set the data to/from
% the pre-wt and post-wt matrices.
% 
% $Id: wt_dims.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

if nargin < 1
  error('Need input size(s)');
end
in_dims = find(sz > 1);
max_scale = min(ceil(log2(sz(in_dims))));
if nargin < 2
  scales = [];
end
if isempty(scales), scales = max_scale; end
if scales > max_scale
  error(sprintf(['Scale %d too high. Maximum scale ' ...
		 'for these dimensions is %d'], scales, max_scale));
end
n_dims = length(sz);
if nargin < 3
  p_dims = ones(1, n_dims);
end
		 
% default outputs
sz = sz(:)';
wt_sz = sz;
sc_in_sz = ones(scales, 1) * sz;
sc_out_sz = sc_in_sz;

% avoid dimensions size 1
in_dims = find(sz > 1 & p_dims);
if isempty(in_dims), return, end

% find scale sizes
next_sizes = sz(in_dims);
for sc = 1:scales
  sc_in_sz(sc, in_dims) = next_sizes;
  next_sizes =  ceil(sc_in_sz(sc, in_dims) / 2);
  sc_out_sz(sc, in_dims) = next_sizes * 2;
end

% overall output size
wt_sz(in_dims) = sc_out_sz(scales, in_dims) ...
    + sum(sc_out_sz(1:scales-1, in_dims)/2, 1);
