% Use marker size to show significance
addpath('..\')

rng(12)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 10) + [(linspace(-1,2.5,20)').*ones(1,5), (linspace(.5,-.7,20)').*ones(1,5)];
Y = randn(20, 12) + [(linspace(.5,-.7,20)').*ones(1,8), (linspace(.9,-.2,20)').*ones(1,4)];
% Get the correlation matrix (求相关系数矩阵)
[rho, pval] = corr(Y, X);
% Define row and column labels (定义行列标签)
rowName = {'Y1','Y2','Y3','Y4','Y5','Y6','Y7','Y8','Y9','Y10','Y11','Y12'};
colName = {'X1','X2','X3','X4','X5','X6','X7','X8','X9','X10'};

% Create and draw the main correlation heatmap (创建并绘制主相关系数热图)
SHMr = SHeatmap(rho, 'Format','sq');
SHMr.RowName = rowName;
SHMr.ColName = colName;
SHMr.draw()
SHMr.setFrame()

% Custom colormap: green → white → purple (自定义颜色映射：绿→白→紫)
cmap = interp1([0,.5,1], [139,201,79; 255,255,255; 202,149,254]./255, linspace(0,1,32));
% cmap = interp1([0,.5,1], [255,193,91; 255,255,255; 85,147,84]./255, linspace(0,1,32));
colormap(SHMr.ax, cmap)
SHMr.freezeColors()

% Add colorbar (添加颜色条)
scbar = SColorbar(gca, 'Location','southeast');
scbar.draw()
scbar.setXYTLim('YLim',[6.5, 12.5])
scbar.freezeColors()
text(11, 6, "Pearson's r", 'FontSize',17, 'FontName','Times New Roman')

% Convert p-values to significance levels (将p值转换为显著性等级)
% 1: p<0.05, 2: p<0.01, 3: p<0.001
pcirc = zeros(size(pval));
pcirc(pval < 0.05) = 1;
pcirc(pval < 0.01) = 2;
pcirc(pval < 0.001) = 3;

% Create a separate heatmap to display significance circles (创建单独的热图显示显著性圆圈)
SHMp = SHeatmap(pcirc, 'Format','acirc');
SHMp.draw()
SHMp.setFrame('Visible','off')
SHMp.setBox('Visible','off')
SHMp.setRowTickIndices([])
SHMp.setColTickIndices([])
SHMp.setPatch('FaceColor','none', 'EdgeColor','k')
delete(SHMp.Colorbar)

% Add legend (添加图例)
slgd = SLegend(SHMp, 'Tick', [3,2,1], 'TitleString','Significance', 'BasePos',[11,1.5], ...
    'Label', {'p < 0.001', 'p < 0.01', 'p < 0.05'});
slgd.draw()
slgd.setPatch('FaceColor','none', 'EdgeColor','k')
slgd.setBox('Visible','off')