function  [h,g,rh,rg]=lemarie(num_coefs)

%LEMARIE    Generates the quadrature filters given by Battle and Lemarie.
%
%	    [H,G,RH,RG] = LEMARIE (NUM_COEFS) returns the coeficients of
%	    orthonormal  Battle-Lemarie wavelets. NUM_COEFS specifies the
%           number of coefficients. 
%
%	    H is the analysis lowpass filter, RH the synthesis lowpass 
%	    filter, G the analysis higthpass filter and RG the synthesis
%	    highpass filter.
%
%	    References: S. Mallat, "A Theory for Multiresolution Signal
%	    		Decomposition: The Wavelet Representation", IEEE Trans.
%			on Patt. An. and Mach. Intell., July 1989
%
% $Id: lemarie.m,v 1.1 2004/09/26 04:00:24 matthewbrett Exp $

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
%       Author: Jose Martin Garcia
%       e-mail: Uvi_Wave@tsc.uvigo.es
%--------------------------------------------------------


% frequency axis
L=128;
w=[0:2*pi/L:2*pi*(1-1/L)];
w(1)=eps;
w(65)=w(65)+1e-15;

% calculation of frequency response of analysis lowpass filter 
num=0;den=0;
K=36;
for k=-K:K,
	num=1./((w+2*pi*k).^8)+num;
	den=1./((2*w+2*pi*k).^8)+den;
end
H=sqrt(num./(2.^8*den));
H(1)=1;

% obtain the time response of lowpass filter
h=real(ifft(H,L));
h=[ h(128-floor(num_coefs/2)+1:128) h(1:ceil(num_coefs/2))];
h=sqrt(2)/sum(h)*h;

[rh,rg,h,g]=rh2rg(fliplr(h));