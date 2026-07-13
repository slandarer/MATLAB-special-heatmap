%% Displaying significance
% 显示显著性

% Made up some data casually (随便捏造了点数据)
X = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
[Data, pval] = corr(X);

% create figure (图窗创建)
figure('Units','normalized', 'Position',[.1,.05,.45,.72])

% Draw heat map with texts (绘制有文本热图)
SHM12 = SHeatmap(Data, 'Format','sq').draw();
SHM12.setText().setType('tril');

% Displaying significance (显示显著性)
SHM12.showStars(pval, 'Levels', [0.05, 0.01, 0.001])
% exportgraphics(gca,'gallery\Significance1.png')

SHM12.showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
% exportgraphics(gca,'gallery\Significance2.png')