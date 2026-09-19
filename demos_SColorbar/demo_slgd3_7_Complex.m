%% Complex heatmap 7
% Inspired by : Fig. 3A
%     Liang WW, Müller S, Hart SK, et al. 
%     RETRACTED: Transcriptome-scale RNA-targeting CRISPR screens reveal essential lncRNAs in human cells 
%     [retracted in: Cell. 2025 Dec 24;188(26):7629. doi: 10.1016/j.cell.2025.11.032.]. 
%     Cell. 2024;187(26):7637-7654.e29. doi:10.1016/j.cell.2024.10.021
%
% Knockdown of shared essential lncRNAs reduces cell survival.

addpath('..\')
T = load('..\data_example\lncRNA.mat');

fig = figure('Units','normalized', 'Position',[.05,.02,.5,.9]);
ax = axes('Parent',fig, 'Position',[.05,.05,.9,.9]);

% Draw left heatmap (绘制左侧热图)
SHM_L = SHeatmap(T.DataL, 'ColGroup',T.colGroup, 'GroupSep',.25, 'TickLength',0);
SHM_L.draw()
SHM_L.setColName(T.colNameL)
SHM_L.setColLabel('Rotation',90, 'FontSize',14)
SHM_L.setXYTLim('XLim', [0, 12.5])
SHM_L.setRowTickIndices([])
SHM_L.setFontName('Arial')

% Add colorbar (添加颜色条)
colormap(slanCM(19, 32)); clim([0, 1])
scbarL = SColorbar(ax, 'Location','south', 'TickDir','bothin', ...
    'Tick',0:.5:1, 'TickLength',.1);
scbarL.draw()
scbarL.setXYTLim('XLim', [33, 48], 'YLim',[30, 31])
scbarL.setTickLabel('FontName','Arial', 'FontSize',12, 'Rotation',0, ...
    'HorizontalAlignment','center', 'VerticalAlignment','top')

SHM_L.freezeColors()
scbarL.freezeColors()

% Draw left heatmap (绘制右侧热图)
SHM_R = SHeatmap(T.DataR, 'ColGroup',T.colGroup, 'GroupSep',.25, 'TickLength',0);
SHM_R.draw()
SHM_R.setColName(T.colNameR)
SHM_R.setRowName(T.rowName)
SHM_R.setColLabel('Rotation',90, 'FontSize',14)
SHM_R.setRowLabel('FontSize',14)
SHM_R.setRowLabelLocation('right')
SHM_R.setXYTLim('XLim', [18, 30.5])
SHM_R.setFontName('Arial')
SHM_R.setRowTickIndices([1:5, 16, 23])
spreadLabels(SHM_R.rowLabelHdl, [36,1; 36,25], 'LeaderStyle','segment2', 'UniformWeight',.6)

% Add colorbar (添加颜色条)
tcmap = flipud(slanCM(4, 128));
colormap(tcmap((1:64) + 15, :)); clim([0, 1])
scbarR = SColorbar(ax, 'Location','south', 'TickDir','bothin', ...
    'Tick',0:.5:1, 'TickLength',.1);
scbarR.draw()
scbarR.setXYTLim('XLim', [33, 48], 'YLim',[45, 46])
scbarR.setTickLabel('FontName','Arial', 'FontSize',12, 'Rotation',0, ...
    'HorizontalAlignment','center', 'VerticalAlignment','top')

SHM_R.freezeColors()
scbarR.freezeColors()

% Draw group blocks 1
[ind, ~, ~] = unique(T.rowGroup1, 'stable');
CList1 = [206,62,82; 232,107,70; 236,169,90; 245,213,136; 220,234,146; 96,185,157; 41,129,186]./255;
SCB1 = SClusterBlock(T.rowGroup1, 'Orientation','left', 'Parent',ax, ...
    'Height',2, 'BasePos',-.5, 'BlockProp',{'LineWidth',.5, 'EdgeColor','none'}, 'ColorList',CList1(ind, :));
SCB1.draw(); % SCB1.setBox('Color','w', 'LineWidth',.5)

% Draw group blocks 2
[ind, ~, ~] = unique(T.rowGroup2, 'stable');
CList2 = [255,255,255; 3,103,45; 217,217,217]./255;
SCB2 = SClusterBlock(T.rowGroup2, 'Orientation','right', 'Parent',ax, ...
    'Height',2, 'BasePos',13, 'BlockProp',{'LineWidth',.5, 'EdgeColor','none'}, 'ColorList',CList2(ind, :));
SCB2.draw(); % SCB2.setBox('Color','w', 'LineWidth',.5)


% Add legend2 (添加图例2)
[~, ~, ticks2] = intersect(1:max(T.rowGroup2), SCB2.ClassName, 'stable');
slgd2 = SLegend(SCB2, 'BasePos',[33, 37], 'TitleString','Essentiality (CRISPRI)', ...
    'IconSize',[1, 1], 'RowSep',1, 'LabelOffset',.25, 'Tick',ticks2(2:3), 'Label', T.rowGroupName2(2:3));
slgd2.draw()
slgd2.setLabel('FontName','Arial')
slgd2.setTitle('FontName','Arial')

% Add legend1 (添加图例1)
[~, ~, ticks1] = intersect(1:max(T.rowGroup1), SCB1.ClassName, 'stable');
slgd1 = SLegend(SCB1, 'BasePos',[33, 52], 'TitleString','Genomic class', ...
    'IconSize',[1, 1], 'RowSep',1, 'LabelOffset',.25, 'Tick',ticks1, 'Label', T.rowGroupName1);
slgd1.draw()
slgd1.setLabel('FontName','Arial')
slgd1.setTitle('FontName','Arial')



% Create annotations 
text(ax, 33, 28.5, 'Essentiality rank (Cas13)', 'FontName','Arial', 'FontSize',17)
text(ax, 33, 43.5, 'Expression (log_2 TPM+1)', 'FontName','Arial', 'FontSize',17)
plot(ax, [0, 15], [0,0], 'Color','k', 'LineWidth',2)
plot(ax, [18, 30.5], [0,0], 'Color','k', 'LineWidth',2)
text(ax, 7.5, -1.5, 'Essentiality', 'FontName','Arial', 'FontSize',17, 'HorizontalAlignment','center')
text(ax, 24.25, -1.5, 'Expression', 'FontName','Arial', 'FontSize',17, 'HorizontalAlignment','center')