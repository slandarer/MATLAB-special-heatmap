%% Complex heatmap
% Inspired by : Fig. 3e
%     Elmentaite, R., Kumasaka, N., Roberts, K. et al. 
%     Cells of the human intestinal tract mapped across space and time. 
%     Nature 597, 250–255 (2021). https://doi.org/10.1038/s41586-021-03852-1
%
% Cells of the developing enteric nervous system.


addpath('..\')

T = load('..\data_example\HSCR.mat');

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.1,.7,.65]);
ax = axes('Parent',fig, 'Position',[.025,.025,.9,.95]);

% Draw the left dendrogram (绘制左侧树状图)
orderL = SDendrogram(T.Data, 'Orientation','left', 'Parent',ax, 'BasePos',.5, 'Height',3).draw();

% Draw the heatmap
SHM = SHeatmap(T.Data(orderL, :), 'RowName',T.rowName(orderL), 'GroupLabelOffset',1.5, 'GroupSep',0);
[names0, ~, group0] = unique(T.colGroup0, 'stable');
SHM.ColGroup = group0;
SHM.draw()
colormap(flipud(slanCM(97, 32)))
SHM.setRowLabel('FontSize',14)
SHM.setRowLabelLocation('right')
SHM.setColGroupName(names0)
SHM.setColGroupLabelLocation('top')

% Draw group blocks 0
SCB0 = SClusterBlock(group0, 'Orientation','top', 'Parent',ax, ...
    'Group',group0, 'ColorList',[0,0,0; 0 0 0], 'Height',.15, ...
    'BlockProp',{'EdgeColor','none'});
SCB0.draw(); SCB0.setXYTLim('XLim', SHM.XLim)

% Draw group blocks 2
SCB2 = SClusterBlock(T.colGroup2, 'Orientation','bottom', 'Parent',ax, ...
    'ColorList',[231,173,195; 207,221,239]./255, 'Height',.75, 'BasePos',13.75, ...
    'BlockProp',{'EdgeColor','none'});
SCB2.draw(); SCB2.setBox('Color','w', 'LineWidth',.5)

% Draw group blocks 3
SCB3 = SClusterBlock(T.colGroup3, 'Orientation','bottom', 'Parent',ax, ...
    'ColorList',[113,71,143; 208,186,47]./255, 'Height',.75, 'BasePos',14.5, ...
    'BlockProp',{'EdgeColor','none'});
SCB3.draw(); SCB3.setBox('Color','w', 'LineWidth',.5)

% Draw group blocks 1
SCB1 = SClusterBlock(T.colGroup1, 'Orientation','bottom', 'Parent',ax, ...
    'ColorList',[113,71,143; 208,186,47]./255, 'Height',3.5, 'BasePos',13.75, ...
    'Format','bounds');
[X1, Y1] = SCB1.draw();
[names1, ~, ~] = unique(T.colGroup1, 'stable');
text(ax, X1, Y1, names1, 'FontName','Times New Roman', ...
    'FontSize',14, 'HorizontalAlignment','right', 'Rotation',90);

% Draw colorbar
scbar = SColorbar(ax, 'Tick',0:.5:1.5);
scbar.draw()
scbar.setXYTLim('YLim',[10,17], 'XLim',[-5,-4])
text(ax, -5.25, 13.5, 'Mean expression', 'FontName','Times New Roman', ...
    'FontSize',15, 'HorizontalAlignment','center', 'Rotation',90, 'VerticalAlignment','bottom');

% Draw legend 1
slgd1 = SLegend(SCB2, 'RowSep',.25, 'BasePos',[-6.25,18], 'LabelOffset',.25);
slgd1.draw(); %slgd1.setBox('Visible','off')

% Draw legend 2
slgd2 = SLegend(SCB3, 'RowSep',.25, 'BasePos',[-6.25,21], 'LabelOffset',.25);
slgd2.draw(); %slgd2.setBox('Visible','off')