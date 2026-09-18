%% Complex heatmap 6
% Inspired by : Extended Data Fig. 3b
%     Garrido-Sanz, D., Keel, C. 
%     Seed-borne bacteria drive wheat rhizosphere microbiome assembly 
%     via niche partitioning and facilitation. Nat Microbiol 10, 
%     1130–1144 (2025). https://doi.org/10.1038/s41564-025-01973-1
%
% Overall functional content of samples.

addpath('..\')
T = load('..\data_example\BRITE_TPM1000.mat');

CList = [137,137,137; 66,94,128; 11,126,78; 141,147,111; 123,66,92; 215,164,111]./255;

fig = figure('Units','normalized', 'Position',[.05,.1,.9,.8]);
ax = axes('Parent',fig, 'Position',[.025,.05,.85,.65]);

% Draw the left dendrogram (绘制左侧树状图)
SDL = SDendrogram(T.Data, 'Orientation','left', 'Parent',ax, 'BasePos',-1.5, 'Height',20, 'MaxClust',3, 'GroupSep',.25);  
[orderL, groupL] = SDL.draw();
SDL.setXYTLim('YLim',[0,60])
set(SDL.treeHdl, 'LineWidth',1.5)

% Draw group blocks 1
SCB1 = SClusterBlock(T.colGroup1, 'Orientation','top', 'Parent',ax, ...
    'BlockInset',.4, 'Height',3, 'BasePos',-4.5, 'Format','tailbrack', ...
    'BlockProp',{'LineWidth',1.5});
[X, Y] = SCB1.draw();
text(ax, X, Y - 2.5, T.colGroupNames1, 'FontName','Arial', 'FontSize',12, 'Rotation',45)
[~, ind, ~] = unique(T.colGroup1, 'stable');
set(SCB1.blockHdl, {'EdgeColor'}, num2cell(CList(T.colGroup0(ind), :), 2))
% Draw group blocks 0
SCB0 = SClusterBlock(T.colGroup0, 'Orientation','top', 'Parent',ax, ...
    'Height',1.5, 'BasePos',-1.5, 'BlockProp',{'EdgeColor','none'}, 'ColorList',CList, 'BlockInset',.1);
SCB0.draw();

% Draw heatmap (绘制热图)
SHM = SHeatmap(T.Data(orderL, :), 'Format','sqfull', 'GroupSep',.25, 'TickLength',0, 'RowGroup',T.rowGroup);
SHM.draw()
SHM.setColTickIndices([])
SHM.setRowLabelLocation('right')
SHM.setRowName(T.rowNames(orderL))
SHM.setRowLabel('FontName','Arial', 'FontSize',12)
SHM.setXYTLim('YLim',[0,60])

% Add colorbar (添加颜色条)
colormap(flipud(slanCM(59, 32)))
clim([0,5.2])
scbar = SColorbar(ax, 'Location','south', 'TickDir','bothin', 'Tick',0:5, 'TickLength',1);
scbar.draw()
scbar.setXYTLim('XLim',[-5, 25], 'YLim',[75,80])
scbar.setTickLabel('FontName','Arial', 'FontSize',12, 'Rotation',0, ...
    'HorizontalAlignment','center', 'VerticalAlignment','top')
scbar.setFrame('LineWidth',1.5, 'Color','w')
text(ax, -5, 69, 'log_{10}(TPMs)', 'FontName','Arial', 'FontWeight','bold', 'FontSize',17)


% Add legend (添加图例)
slgd = SLegend(SCB0, 'BasePos',[45, 75], 'RowSep',2, 'TitleString','Brite hierarchies', ...
    'ColNum',3, 'ColSep',65, 'IconSize',[4,4], 'RowSep',4, 'LabelOffset',2, 'Label',T.colGroupNames0);
slgd.draw()
slgd.setBox('LineWidth',1.5)
slgd.setLabel('FontName','Arial')
slgd.setTitle('FontName','Arial', 'FontWeight','bold')