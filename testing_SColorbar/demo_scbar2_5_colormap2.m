%% Heatmap with 2 colormaps (circ2_1)

addpath('..\')

rng(1)
Data1 = (rand(50, 5) - .5).*2;
Data2 = (rand(50, 4) - .5).*200;
clim1 = [-1, 1];
clim2 = [-100, 100];
group = [ones(1, 8), 2.*ones(1, 12), 3.*ones(1, 10), 4.*ones(1, 20)];
rowName = compose('r-%d', 1:50);
colName1 = compose('A-%d', 1:5);
colName2 = compose('B-%d', 1:4);

fig = figure('Units','normalized', 'Position',[.05,.05,.65,.9]);
ax = axes('Parent',fig, 'Position',[.05,.05,.9,.9]);

%% Circular heatmap 1
SHM1 = SHeatmap(ax, Data1, 'Format','sqfull', 'RowGroup',group, 'TickLength', .3).draw();
SHM1.setRowName(rowName)
SHM1.setColName(colName1)
SHM1.setColLabelLocation('top')
SHM1.setXYTLim('XLim',[2.7,3.7], 'YLim',[0, 1], 'TLim',[-3*pi/2, pi/3]);

% Set colormap 
colormap(ax, slanCM(100, 32))
clim(ax, clim1)
SHM1.freezeColors()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','north', 'TickLength',.05, 'TickLabelOffset',.05);
scbar1.draw()
scbar1.setXYTLim('XLim',[-1.7,1.7], 'YLim', -[.2,.4])
scbar1.freezeColors()

%% Circular heatmap 2
SHM2 = SHeatmap(ax, Data2, 'Format','sqfull', 'RowGroup',group, 'TickLength', .3).draw();
SHM2.setRowName(rowName)
SHM2.setColName(colName2)
SHM2.setRowLabelLocation('right')
SHM2.setColLabelLocation('top')
SHM2.setXYTLim('XLim',[4, 5], 'YLim',[0, 1], 'TLim',[-3*pi/2, pi/3]);

% Set colormap 
colormap(ax, slanCM(97, 32))
clim(ax, clim2)

% Add colorbar1 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','south', 'TickLength',.05, 'TickLabelOffset',.05);
scbar2.draw()
scbar2.setXYTLim('XLim',[-1.7,1.7], 'YLim', [.2,.4])
