function [rho, pval, rperm] = mantel(dist1, dist2, varargin)
% MANTEL - Mantel test for matrix correlation
%   rho = mantel(dist1, dist2) performs Mantel test with 999 permutations
%   using Pearson correlation.
%
%   rho = mantel(dist1, dist2, nperm) specifies number of permutations.
%
%   rho = mantel(dist1, dist2, method) specifies correlation method
%         ('Pearson' or 'Spearman', default 'Pearson').
%
%   rho = mantel(dist1, dist2, nperm, method) sets both.
%
%   [rho, pval] = mantel(___) also returns the p-value (one-sided).
%
%   [rho, pval, rperm] = mantel(___) returns the permuted r values.


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
V1 = dist1(ind);
V2 = dist2(ind);

% Observed correlation
rho = corr(V1, V2, 'Type', method);

% Permutation test
rperm = zeros(nperm, 1);
for i = 1:nperm
    perm = randperm(N);
    dist2_perm = dist2(perm, perm);
    V2_perm = dist2_perm(ind);
    rperm(i) = corr(V1, V2_perm, 'Type', method);
end

% p-value (one-sided, positive correlation)
pval = (sum(rperm >= rho) + 1) / (nperm + 1);
end