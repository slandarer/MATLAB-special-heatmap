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

% Convert p-values to -log10(p) for marker size (将p值转换为 -log10(p) 用于标记大小)
neglog10pval = -log(pval)/log(10);

% Create and draw the main correlation heatmap (创建并绘制主相关系数热图)
SHM = SHeatmap(neglog10pval, 'Format','acirc');
SHM.RowName = rowName;
SHM.ColName = colName;
SHM.draw()
SHM.setFrame()
SHM.setPatch('EdgeColor','k')
SHM.setBox('Visible','off')
SHM.setExtGrid()

% Add legend (添加图例)
slgd = SLegend(SHM, 'Tick', [3, 2, 1.301], 'TitleString','-log_{10}(pval)', 'BasePos',[11,1.5]);
slgd.draw()
slgd.setPatch('FaceColor','none', 'EdgeColor','k')
slgd.setBox('Visible','off')

% Update CData with correlation coefficients (用相关系数更新颜色数据)
SHM.setCData(rho)
% Custom colormap: green → white → purple (自定义颜色映射：绿→白→紫)
cmap = interp1([0,.5,1], [139,201,79; 255,255,255; 202,149,254]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)
clim([-1, 1])

% Add colorbar (添加颜色条)
scbar = SColorbar(gca, 'Location','southeast');
scbar.draw()
scbar.setXYTLim('YLim',[6.5, 12.5], 'XLim',[11, 11.5])
text(11, 6, "Pearson's r", 'FontSize',17, 'FontName','Times New Roman')





