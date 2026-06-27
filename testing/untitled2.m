% Made up some data casually (随便捏造了点数据)
rng(1)
X1 = randn(100,20) + [(linspace(-1,2.5,100)').*ones(1,8), (linspace(.5,-.7,100)').*ones(1,5), (linspace(.9,-.2,100)').*ones(1,7)];
X2 = randn(100,5)  + [(linspace(-1,2.5,100)').*ones(1,1), (linspace(.5,-.7,100)').*ones(1,2), (linspace(.9,-.2,100)').*ones(1,2)];


% writematrix(X1, 'X1.csv');
% writematrix(X2, 'X2.csv');

rng(4)

D1 = squareform(pdist(X1));
D2 = squareform(pdist(X2));
[rho, pval] = mantel(D1, D2)

bray_func = @(u, v) sum(abs(u - v), 2) ./ sum(u + v, 2);
D_spec = squareform(pdist(X1, bray_func))