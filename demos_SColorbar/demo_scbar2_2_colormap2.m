%% Heatmap with 2 colormaps (tri2_2)

addpath('..\')

% Made up some data casually (随便捏造了点数据)
X1 = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
X2 = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data1 = corr(X1);
Data2 = corr(X2);

figure('Units','normalized', 'Position',[.1,.05,.7,.7])
% Draw the first heatmap and freeze colors (绘制第一个热图并冻结配色)
SHM1 = SHeatmap(Data1, 'Format','triul').draw().setType('tril');
clim([-1,1])
SHM1.freezeColors() 

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','east', 'BasePos',size(Data1, 2) + 2);
scbar1.draw()
scbar1.freezeColors()

% Draw heatmap2
SHM2 = SHeatmap(Data2, 'Format','trilr').draw().setType('tril');
colormap(cool(32));
clim([-1,1])

% Add colorbar1 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','east', 'BasePos',size(Data1, 2) + 4.5);
scbar2.draw()

text(size(Data1, 2) + 2 - .1, size(Data1, 1)/2, 'Prop1', 'FontSize',20, ...
    'HorizontalAlignment','center', 'VerticalAlignment','bottom', ...
    'FontName','Times New Roman', 'Rotation',90)
text(size(Data1, 2) + 4.5 - .1, size(Data1, 1)/2, 'Prop2', 'FontSize',20, ...
    'HorizontalAlignment','center', 'VerticalAlignment','bottom', ...
    'FontName','Times New Roman', 'Rotation',90)