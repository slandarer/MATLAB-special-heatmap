%% Complex heatmap 2
% Inspired by : 
%     Fu Z, Song Y, Liu F, Chen L, Cai S, Cui P, Wang G, Xie W, Zhang S, Ding L, 
%     Wang P, Zhang B, Rodriguez H, Feng F, Zhang X, Gong W, Gao Q, Gao D, Zhou H, Fan J. 
%     Integrative proteogenomic analysis provides molecular insights and clinical significance in gallbladder cancer. 
%     Cancer Cell. 2026 Feb 9;44(2):405-423.e13. doi: 10.1016/j.ccell.2025.12.014. Epub 2026 Jan 8. PMID: 41512870.

addpath('..\')

T = load('..\data_example\mmc6.mat');

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.05,.5,.88]);
ax = axes('Parent',fig, 'Position',[.005,.05,.8,.9]);

[~, ~, rowGroup] = unique(T.PathwayCategory, 'stable');
[~, ~, colGroup] = unique(T.ImmuneClusters, 'stable');
SHM = SHeatmap(T.Data, 'RowGroup',rowGroup, 'ColGroup',colGroup, 'GroupSep',[.4, .2], ...
    'RowName', T.Pathway, 'Type','row', 'TickLength',0);
SHM.draw()
SHM.setRowLabelLocation('right')
SHM.setXYTLim('XLim', [.5, 8.5])
SHM.setFrame('Visible','off')
SHM.setBox('Color','w', 'LineWidth',.5)
SHM.setText('Color','k', 'FontSize',12)
SHM.setText(T.Significance == 1, 'String','*')
SHM.setText(T.Significance == 0, 'String',' ')
SHM.setFontName('Arial')

% Draw left group blocks
SCBL = SClusterBlock(T.PathwayCategory, 'Orientation','left', 'Parent',ax, ...
    'Group',rowGroup, 'ColorList',T.CListP, 'Height',1, 'BasePos',.1, ...
    'BlockProp',{'EdgeColor','none'}, 'GroupSep',.4);
SCBL.draw();
SCBL.setBox('Color','w', 'LineWidth',.5)

% Draw top group blocks
SCBT = SClusterBlock(T.ImmuneClusters, 'Orientation','top', 'Parent',ax, ...
    'Group',colGroup, 'ColorList',T.CListI, 'Height',1, 'BasePos',.1, ...
    'BlockProp',{'EdgeColor','none'}, 'GroupSep',.2);
SCBT.draw();
SCBT.setXYTLim('XLim', SHM.XLim)
SCBT.setBox('Color','w', 'LineWidth',.5)

cmap = interp1([-1.5, -1, 0, 1, 1.5], T.CListC, linspace(-1.5, 1.5, 32));
colormap(cmap)
clim([-1.5, 1.5])

% Draw legend 1
slgd1 = SLegend(SCBT, 'BasePos',[28, 21], 'TitleString','Immune clusters');
slgd1.draw(); 
slgd1.setBox('Color','w')
slgd1.setLabel('FontName','Arial', 'FontSize',13)
slgd1.setTitle('FontName','Arial', 'FontSize',13, 'VerticalAlignment','bottom')

% Draw legend 2
slgd2 = SLegend(SCBL, 'BasePos',[28, 27.5], 'TitleString','Pathway category');
slgd2.draw(); 
slgd2.setBox('Color','w')
slgd2.setLabel('FontName','Arial', 'FontSize',13)
slgd2.setTitle('FontName','Arial', 'FontSize',13, 'VerticalAlignment','bottom')

% Draw colorbar
scbar = SColorbar(ax, 'Tick',-1:1:1);
scbar.draw()
scbar.setXYTLim('YLim',[37,43], 'XLim',[28, 29])
scbar.setTickLabel('FontName','Arial', 'FontSize',13)
text(ax, 28, 36, 'Pathway activity', 'FontName','Arial', 'FontSize',13)
