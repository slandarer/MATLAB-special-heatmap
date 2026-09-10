%% Complex heatmap 4
% Inspired by : Fig. 1b
%     Wang, Y., Ma, A., Song, NJ. et al. 
%     Proteotoxic stress response drives T cell exhaustion and immune evasion. 
%     Nature 647, 1025–1035 (2025). https://doi.org/10.1038/s41586-025-09539-1
%
% PSR is triggered in Tex cells with a dynamic expression of chaperone proteins.

addpath('..\')

T = load('..\data_example\LCMV.mat');
rowName = strrep(T.rowName, '_', ' ');

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.05,.8,.6]);
ax = axes('Parent',fig, 'Position',[.25,.05,.7,.9]);

SHM = SHeatmap(T.Data, 'Format','rrect', 'Type','row', 'RowName',rowName);
SHM.draw()
SHM.setFrame('Visible','off')
SHM.setRowLabel('FontName','Arial', 'FontSize',15)

cmap = interp1([0,.5,1], [105,170,219; 255,255,255; 212,85,144]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)
% Add colorbar (添加颜色条)
scbar = SColorbar(ax, 'Location','south', 'Tick',-2:1:2);
scbar.draw()
scbar.setXYTLim('XLim',[25.5,31.5], 'YLim',[13,13.5])
scbar.setTickLabel('FontName','Arial', 'HorizontalAlignment','center', 'VerticalAlignment','top', 'Rotation',0)
text(ax, 28.5, 12.25, 'Activation score', 'FontName','Arial', 'FontSize',17, 'HorizontalAlignment','center')

names = erase(T.colName, regexpPattern('_rep\d+'));
[cnames1, ~, group1] = unique(names, 'stable');
clist1 = [218,187,200; 150,173,194; 196,220,219; 137,182,179; 196,184,203; 203,211,222; 181,216,224; 141,184,203; 113,155,169]./255;
% Draw group blocks 1
SCB1 = SClusterBlock(group1, 'Orientation','top', 'Parent',ax, ...
    'Group',group1, 'ColorList',clist1, 'Height',.2, ...
    'BlockProp',{'EdgeColor','none'}, 'GroupSep',.1, 'BasePos',.25);
SCB1.draw(); SCB1.setXYTLim('XLim', SHM.XLim)

cnames1 = regexprep(cnames1, '.*_', '');
text(ax, SCB1.X, SCB1.Y - .75, cnames1, 'FontName','Arial', 'FontSize',15, 'HorizontalAlignment','center')


cnames2 = regexprep(names, '_[^_]+$', '');
cnames2 = strrep(cnames2, '_', ' ');
clist2 = [100,100,100; 100,100,100; 100,100,100; 100,100,100]./255;
[cnames2, ~, group2] = unique(cnames2, 'stable');
% Draw group blocks 2
SCB2 = SClusterBlock(group2, 'Orientation','top', 'Parent',ax, ...
    'Group',group2, 'ColorList',clist2, 'Height',.2, ...
    'BlockProp',{'EdgeColor','none'}, 'GroupSep',.1, 'BasePos',-1.25);
SCB2.draw(); SCB2.setXYTLim('XLim', SHM.XLim)
text(ax, SCB2.X, SCB2.Y - .75, cnames2, 'FontName','Arial', 'FontSize',15, 'HorizontalAlignment','center')