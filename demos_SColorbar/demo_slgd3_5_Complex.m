%% Complex heatmap 4
% Inspired by : Fig. 1c
%     Garrido-Sanz, D., Keel, C. 
%     Seed-borne bacteria drive wheat rhizosphere microbiome assembly 
%     via niche partitioning and facilitation. Nat Microbiol 10, 
%     1130–1144 (2025). https://doi.org/10.1038/s41564-025-01973-1
%
% Sequential succession of a wheat rhizosphere microbiome.

addpath('..\')
T = load('..\data_example\WRM.mat');

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.05,.6,.8]);
ax = axes('Parent',fig, 'Position',[.025,.05,.9,.9]);

[orderL, clustL] = SDendrogram(T.Data, 'Orientation','left', 'Parent',ax, 'BasePos',-.5, 'Height',4, 'MaxClust',3, 'GroupSep',.25).draw();  % Draw the left dendrogram (绘制左侧树状图)
[orderT, clustT] = SDendrogram(T.Data, 'Orientation','top' , 'Parent',ax, 'BasePos',-.5, 'Height',4, 'MaxClust',3, 'GroupSep',.25).draw();  % Draw the top  dendrogram (绘制顶部树状图)
group = T.group(orderT);
CList = [163,172,78; 103,158,54; 69,141,60; 45,125,66; 44,112,86; 44,115,111; 10,155,132; 176,127,130; 227,179,180; 207,163,64]./255;

Data = T.Data(orderL, orderT);  % Exchange data order (交换数据顺序)
SCBL = SClusterBlock(group, 'ColorList',CList ,'Orientation','left', 'Parent',ax, 'BasePos',.5, 'Group',clustL, 'GroupSep',.25);
SCBL.draw(); % Draw the left Block (绘制左侧分组方块)
SCBT = SClusterBlock(group, 'ColorList',CList, 'Orientation','top' , 'Parent',ax, 'BasePos',.5, 'Group',clustT, 'GroupSep',.25);
SCBT.draw(); % Draw the top  Block (绘制顶部分组方块)

% Draw heatmap (绘制热图)
SHM = SHeatmap(Data, 'Format','sqfull', 'Parent',ax, ...
    'RowGroup',clustL, 'ColGroup',clustT, 'GroupSep',.25);
SHM.draw();
SHM.setRowTickIndices([])
SHM.setColTickIndices([])
SHM.setFrame()

% Add colorbar (添加颜色条)
clim([0, 1]); colormap(slanCM(4, 32))
scbar = SColorbar(ax, 'Location','east', 'TickDir','out', 'Tick',0:.5:1, 'TickLength',.2);
scbar.draw()
scbar.setXYTLim('YLim',[28.75, 41], 'XLim',[42,43])


% Add legend (添加图例)
[~, ~, ticks] = intersect(T.groupNameMap(:, 1), SCBT.ClassName, 'stable');
slgd = SLegend(SCBT, 'BasePos',[42, 2], 'RowSep',1.25, 'Tick',ticks, 'Label',T.groupNameMap(:, 2), 'TitleString','Samples');
slgd.draw()

text(ax, 42, 26, {'Bray-Curtis';'dissimilarity'}, 'FontSize',17, 'FontName','Times New Roman')
text(ax, 45, 12.625, {'Succession';'cycle'}, 'FontSize',17, 'FontName','Times New Roman', ...
    'HorizontalAlignment','center', 'VerticalAlignment','top', 'Rotation',90)
plot(ax, [44.5, 44.5], [6.5, 18.75], 'Color','k', 'LineWidth',1)