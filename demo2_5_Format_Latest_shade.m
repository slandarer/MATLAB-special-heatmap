%% Latest format - shade
% Negative parts are shaded with diagonal lines
% 负数部分阴影填充

figure()
rng(6)
% Made up some data casually (随便捏造了点数据)
X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

SHM = SHeatmap(Data, 'Format','shade');
SHM.draw();
SHM.setType('triu')
SHM.setFrame()

colormap(slanCM(141, 32))