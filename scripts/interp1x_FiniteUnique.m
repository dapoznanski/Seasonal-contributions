function[yq] = interp1x_FiniteUnique(x, y, xq, extrap)

% [yq] = interp1x_FiniteUnique(x, y, xq, extrap)
%
% Interpolates to find yq, the values of the underlying function y=F(x) at 
% the query points xq when x has non-finite and/or repeating values. 
% Calls MATLAB interp1 function after removing non-finite and repeating 
% values from x. Uses Linear interpolation. 
% 
% Inputs: 
%   Set extrap=1 if you want to use linear interpolation to perform 
%   extrapolation for elements of xq that are outside the interval spanned
%   by x. Set extrap=0 to NOT extrapolate. 

% Author: Hannah Baranes 
%   University of Massachusetts Amherst
%   hbaranes@geo.umass.edu 
% Last edited September 2019
    
xtemp = x(isfinite(x));
ytemp = y(isfinite(x)); 

[xtemp, ind] = unique(xtemp); 
ytemp = ytemp(ind); 

if extrap==1
    yq = interp1(xtemp, ytemp, xq, 'linear', 'extrap'); 
else
    yq = interp1(xtemp, ytemp, xq, 'linear'); 
end