% Sector heatmap

% Inspired: https://blogs.mathworks.com/graphics-and-apps/2025/09/30/polar-plots-with-patches-and-surfaces-r2025a/
%           https://github.com/MATLAB-Graphics-and-App-Building/matlab-gaab-blog-2025/blob/main/PolarPatchesAndSurfaces/
% Data source: https://www.ncei.noaa.gov/access/monitoring/climate-at-a-glance/statewide/mapping

T = load('avgT2024.mat');
% Isolate the average, high, and low data
Data = T.Data{:, [6 2 5]};
rowName = T.Data{:, 1};
colName = {'AvgLowF', 'AvgF', 'AvgHighF'};

fig = figure('Units','normalized', 'Position',[.2,.1,.6,.8]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

% Draw sector heatmap (绘制扇形热图)
SHM = SHeatmap(Data, 'Format','sq', 'RowName',rowName, 'ColName',colName, 'TickLength',0, 'TickLabelOffset',.1).draw();
SHM.setRowLabelLocation('right')
SHM.setXYTLim('XLim',[1,2], 'YLim',[0,1], 'TLim',[0, pi]);
SHM.setBox('Color','k', 'LineWidth',1)

set(SHM.colLabelHdl, 'HorizontalAlignment','center', 'VerticalAlignment','top', 'Rotation',0)
text(0, -.2, {'Average Temperature'; '2024'}, 'FontWeight','bold', 'FontSize',25, 'HorizontalAlignment','center')

axis([-2, 2, -2, .2])
colormap("turbo")
clim([0, 100])
SHM.Colorbar.Location = 'southoutside';