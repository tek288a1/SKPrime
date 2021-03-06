classdef greensCjDp < bvpFun
%greensCjDp is the derivative with respect to the parameter of Gj.
%
%  dpgj = greensCjDp(gj)
%    Solves the boundary value problems for the derivative with respect to
%    the parameter of the Greens function with respect to Cj.
%
%  dpgj = greensCjDp(parameter, D)
%
%See also greensC0Dp, bvpFun.

% E. Kropf, 2016
% R. Nelson, 2016
% 
% This file is part of SKPrime.
% 
% SKPrime is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% SKPrime is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with SKPrime.  If not, see <http://www.gnu.org/licenses/>.

properties(SetAccess=protected)
    parameter
    
    partialWrtX
    partialWrtY
    normalizeConstant = 0
end

methods
    function dpgj = greensCjDp(gj, j, varargin)
        alpha = [];
        if ~nargin
            args = {};
        elseif (isa(gj, 'double') || isa(gj, 'skpParameter')) ...
                && nargin == 3 && (isa(varargin{1}, 'skpDomain') ...
                || isa(varargin{1}, 'bvpFun'))
            alpha = gj;
            args = varargin(1);
        elseif isa(gj, 'greensCj')
            alpha = gj.parameter;
            args = {gj};
        else
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Arguments not recognized.')
        end
        
        dpgj = dpgj@bvpFun(args{:});
        if ~nargin
            return
        end
        
        alpha = skpParameter(alpha, dpgj.domain);
        dpgj.parameter = alpha;
        [d, q] = domainData(dpgj.domain);
        
        resx = @(z) 1./(2i*pi)*( 1./(z - alpha) ...
               - 1./(conj(alpha) - conj(d(j))) ...
               + (z - d(j))./((z - d(j)).*(conj(alpha) - conj(d(j))) - q(j)));
        dpgj.partialWrtX = ...
            genericPlusSingular(resx, @(z) -imag(resx(z)), dpgj);        
        
        resy = @(z) 1./(2*pi)*( 1./(z - alpha) ...
               + 1./(conj(alpha) - conj(d(j))) ...
               - (z - d(j))./((z - d(j)).*(conj(alpha) - conj(d(j))) - q(j)));
        dpgj.partialWrtY = ...
            genericPlusSingular(resy, @(z) -imag(resy(z)), dpgj);
        
        dpgj.normalizeConstant = dpgj.hat(alpha) + 1/(4i*pi*(alpha - d(j)));
    end
    
    function ddpgh = diffh(dpgj)
        %gives derivative of the analytic part wrt zeta variable.
        
        ddpgh = dftDerivative(dpgj, @dpgj.hat);
    end
    
    function v = feval(dp, z)
        v = (dp.partialWrtX(z) - 1i*dp.partialWrtY(z))/2 ...
            - dp.normalizeConstant;
    end
    
    function v = hat(dp, z)
        %evalutate the "analytic" part of the function.
        
        v = (dp.partialWrtX.hat(z) - 1i*dp.partialWrtY.hat(z))/2 ...
            - dp.normalizeConstant;
    end
end

methods(Access=protected)
end

end
