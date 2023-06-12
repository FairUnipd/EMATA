function s=maxrsize(lw,k)

% MAXRSIZE  Maximum recoverable size from a Wavelet transform
%
%           MAXRSIZE (LW,K) returns the size of the largest
%           vector that can be reconstructed from the K-scales
%           wavelet transform of length LW. This maximum size
%           can be the same as LW or LW+1 (because of the 
%           transformation method)
%
%	    If there's no vector whose K-scales Wavelet transform
%           is LW samples long, the return value is 0.
%
%           See also: WVLTSIZE, WT, WT2D, BANDSITE.
%
%
% $Id: maxrsize.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

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
%       Author: Sergio J. Garcia Galan 
%       e-mail: Uvi_Wave@tsc.uvigo.es
%--------------------------------------------------------


s=0;
l=0;
x=floor(lw/2);

while (s==0) & (l<=k),
	testsize = x-l;	
	lo(1)=2*testsize;

	for i=1:k
        	lo(i+1)=floor((lo(i)+1)/2);	
	end
	check=sum(lo(2:k+1))+lo(k+1);
	if check==lw,
		s=testsize*2;
	end
	l=l+1;
end