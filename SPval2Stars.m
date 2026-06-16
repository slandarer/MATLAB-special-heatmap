function stars = SPval2Stars(pval, levels)
% SPval2Stars - Convert p-values to significance stars
%   stars = SPval2Stars(pval) returns significance stars:
%       p < 0.05   -> '*'
%       p < 0.01   -> '**'
%       p < 0.001  -> '***'
%
%   stars = SPval2Stars(pval, levels) custom significance thresholds
%       levels = [0.05, 0.01, 0.001] (default)
%
% Examples:
%   SPval2Stars(0.03)   % returns '*'
%   SPval2Stars(0.003)  % returns '***'

if nargin < 2
    levels = [0.05, 0.01, 0.001];
end

% Generate asterisk string based on significance level
stars = repmat('*', 1, sum(pval < levels));
end