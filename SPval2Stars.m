function stars = SPval2Stars(pval, levels)
if nargin < 2
    levels = [0.05, 0.01, 0.001];
end
stars = char(ones(1, sum(pval < levels)).*42);
end