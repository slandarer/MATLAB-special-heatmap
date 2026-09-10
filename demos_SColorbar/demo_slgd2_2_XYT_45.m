% Rotation without deformation is currently supported only for the following formats: 
% 'sq', 'asq', 'circ', 'acirc', 'bcirc', 'cust', 'rrect', 'acust', 'c2rect', and 'arrect'
addpath('..\')

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
[rho, pval] = corr(X);
group = [1,1,1,1,1,1, 2,2,2,2,2, 3,3,3,3];

% Convert p-values to -log10(p) for marker size (将p值转换为 -log10(p) 用于标记大小)
neglog10pval = -log(pval)/log(10);

figure()
SHM = SHeatmap(neglog10pval, 'Format','acirc', 'TickLength',0, 'TickLabelOffset', 0, ...
    'RowGroup',group, 'ColGroup',group, 'GroupLabelOffset',.5);
SHM.draw();
SHM.setType('triu0');
SHM.setPatch('EdgeColor','k')
SHM.setBox('Visible','off')
SHM.setRowTickIndices([])
SHM.setRowGroupName({'Group-A', 'Group-B', 'Group-C'})
SHM.setRowGroupLabelLocation('right')
SHM.setGrid()

% Set theta limits: TLim(1) == TLim(2) -> rotation only, no deformation (rotate by 45°)
% 设置角度范围：TLim(1) == TLim(2) -> 仅旋转不形变 (旋转45度)
SHM.setXYTLim('TLim', [pi/4, pi/4]);
SHM.setFrame('Visible','off')

% Add legend (添加图例)
slgd = SLegend(SHM, 'Tick', [5, 3, 2, 1.301], 'TitleString','-log_{10}(pval)', 'BasePos',[24,-12]);
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
scbar.setXYTLim('YLim',[-6.5, -.5], 'XLim',[24.25, 24.75])
text(24, -7, "Peason's r", 'FontSize',17, 'FontName','Times New Roman')
