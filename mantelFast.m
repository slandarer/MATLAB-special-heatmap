function [rho, pval, rperm] = mantelFast(dist1, dist2, varargin)
% MANTEL - Mantel test for matrix correlation
%   rho = mantelFast(dist1, dist2) performs Mantel test with 999 permutations
%   using Pearson correlation.
%
%   rho = mantelFast(dist1, dist2, nperm) specifies number of permutations.
%
%   rho = mantelFast(dist1, dist2, method) specifies correlation method
%         ('Pearson'(default)/'Kendall'/'Spearman').
%
%   rho = mantelFast(dist1, dist2, nperm, method) sets both.
%
%   [rho, pval] = mantelFast(___) also returns the p-value (one-sided).
%
%   [rho, pval, rperm] = mantelFast(___) returns the permuted r values.

% References
% [1] Mantel N. The detection of disease clustering and a generalized regression approach. 
%     Cancer Res. 1967 Feb;27(2):209-20. PMID: 6018555.
% [2] Borcard, D. & Legendre, P. (2012) Is the Mantel correlogram powerful enough to be 
%     useful in ecological analysis? A simulation study. Ecology 93: 1473-1481.
% [3] Legendre, P. and Legendre, L. (2012) Numerical Ecology. 3rd English Edition. Elsevier.

% Parse input arguments
switch nargin
    case 2
        nperm = 999; method = 'Pearson';
    case 3
        if isnumeric(varargin{1})
            nperm = varargin{1}; method = 'Pearson';
        else
            nperm = 999; method = varargin{1};
        end
    case 4
        nperm = varargin{1}; method = varargin{2};
    otherwise
        error('Invalid number of input arguments.');
end
% Extract lower-triangular vectors
N = size(dist1, 1);
ind = tril(true(N), -1);
V1 = dist1(ind); V2 = dist2(ind);

% Observed correlation
rho = corr(V1, V2, 'Type', method);

% Permutation test
[~, perm] = sort(rand(N, nperm), 1);
[indR, indC] = find(tril(true(N), -1));
V2 = dist2(sub2ind([N, N], perm(indR, :), perm(indC, :)));
rperm = corr(V1, V2, 'Type', method);

% p-value with +1 correction
pval = (sum(rperm >= rho) + 1) / (nperm + 1);
end