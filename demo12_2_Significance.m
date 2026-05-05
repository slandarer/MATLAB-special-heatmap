% 显示显著性(Displaying significance)

% 随便捏造了点数据(Made up some data casually)
X=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,4)];
% 求相关系数矩阵(Get the correlation matrix)
[Data, pval]=corr(X);

% 图窗创建(create figure)
fig=figure('Position',[100,100,870,720]);

% 绘制有文本热图(Draw heat map with texts)
SHM12=SHeatmap(Data,'Format','sq');
SHM12=SHM12.draw();
SHM12.setText();
SHM12.setType('tril0');

% 显示显著性(Displaying significance)
SHM12.showStars(pval, 'Levels', [0.05, 0.01, 0.001])
exportgraphics(gca,'gallery\Significance1.png')

SHM12.showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
exportgraphics(gca,'gallery\Significance2.png')