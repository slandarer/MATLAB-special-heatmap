%% Complex heatmap 3
% Inspired by : Fig. 6d
%     Qie, J., Liu, Y., Wang, Y. et al. 
%     Integrated proteomic and transcriptomic landscape of macrophages in mouse tissues. 
%     Nat Commun 13, 7389 (2022). https://doi.org/10.1038/s41467-022-35095-7
%
% The functional diversity of the tissue-resident and tissue-recruited macrophages in the liver and lung.

addpath('..\')

T = load('..\data_example\liverEPRP.mat');
T = T.Table;

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.05,.5,.8]);
ax = axes('Parent',fig, 'Position',[.05,.05,.9,.9]);

% Draw heatmap left
SHMl = SHeatmap(T{:, 2:7}, 'RowName',T.gene, 'Type','row');
SHMl.draw()

colormap(flipud(slanCM(98, 32)))
clim([-2, 2])

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(ax, 'Location','south', 'TickDir','in', 'Tick', -2:1:2);
scbar1.draw()
scbar1.setTickLabel('Rotation',0, 'HorizontalAlignment','center', 'VerticalAlignment','top')
scbar1.freezeColors()

SHMl.setFrame()
SHMl.setRowLabelLocation('right')
SHMl.freezeColors()


group = {'KC', 'KC', 'KC', 'Liver\_rec', 'Liver\_rec', 'Liver\_rec'};
% Draw group blocks
SCB = SClusterBlock(group, 'Orientation','top', 'Parent',ax, ...
    'ColorList',[105,143,45; 157,191,61]./255, 'Height',.5);
SCB.draw();

SHMr = SHeatmap(T.log2fc, 'Format','bubble', 'BubbleSize',[.3,1.8]);
SHMr.draw()
SHMr.setFrame()
SHMr.setRowName({' '})
SHMr.setColTickIndices([])
SHMr.setXYTLim('XLim', [10, 11])
SHMr.setCData(-log(T.pvalue)./log(10))
SHMr.setPatch('FaceAlpha',.95)
colormap(slanCM(12, 32))

% SHMr.frameHdl.XData(SHMr.frameHdl.XData < 10.4) = SHMr.frameHdl.XData(SHMr.frameHdl.XData < 10.4) - 1;
% SHMr.frameHdl.XData(SHMr.frameHdl.XData > 10.6) = SHMr.frameHdl.XData(SHMr.frameHdl.XData > 10.6) + 1;
% SHMr.extGridHdl.XData(SHMr.extGridHdl.XData < 10.4) = SHMr.extGridHdl.XData(SHMr.extGridHdl.XData < 10.4) - 1;
% SHMr.extGridHdl.XData(SHMr.extGridHdl.XData > 10.6) = SHMr.extGridHdl.XData(SHMr.extGridHdl.XData > 10.6) + 1;
% SHMr.rowTickHdl.XData = SHMr.rowTickHdl.XData - 1;

% Add colorbar2 (添加颜色条2)
scbar2 = SColorbar(ax, 'Location','east', 'TickDir','in', 'Tick',0:.6:2.7);
scbar2.draw()
scbar2.setXYTLim('YLim',[11,17.5], 'XLim',[13,13.5]+.25)
text(ax, 13, 10, '-log10(pvalue)', 'FontSize',17, 'FontName','Times New Roman')

% Draw legend 1
slgd1 = SLegend(SCB, 'RowSep',.25, 'BasePos',[13.25,.5], 'LabelOffset',.25, 'IconSize',[.5,.5]);
slgd1.draw();

% Draw legend 2
slgd2 = SLegend(SHMr, 'RowSep',.6, 'BasePos',[13,4.5], 'LabelOffset',.6, 'Tick',[1,2,4], 'TitleString','log2fc');
slgd2.draw();
slgd2.setPatch('FaceColor',[.7,.7,.7])
slgd2.setBox('Visible','off')

