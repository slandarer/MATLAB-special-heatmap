% Heatmap with 2 colormaps (tri2_1)
addpath('..\')

% Made up some data casually (随便捏造了点数据)
X = randn(20,12) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 4), (linspace(.9,-.2,20)').*ones(1, 2)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

figure()

% Draw heatmap1
SHM1 = SHeatmap(Data, 'Format','sq').draw().setType('tril');
SHM1.setColLabel('Visible','off').setText()
SHM1.freezeColors()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','east');
scbar1.draw()
scbar1.freezeColors()

% Draw heatmap2
SHM2 = SHeatmap(Data, 'Format','donut').draw().setType('triu0');
SHM2.setRowLabel('Visible','off').setColLabel('Visible','on')

% Add colorbar1 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','east');
scbar2.draw()

colormap(slanCM(97, 32))

