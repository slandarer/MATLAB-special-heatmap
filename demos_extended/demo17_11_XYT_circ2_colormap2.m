%% Merge two circular heatmaps with two colormaps
% 合并两个环形热图且使用不同 colormap

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
ax1 = axes('Parent',fig, 'Position',[.05,.05,.9,.9]);
ax2 = axes('Parent',fig, 'Position',[.05,.05,.9,.9], 'Color','none');

%% Circular heatmap 1
SHM1 = SHeatmap(ax1, Data1, 'Format','sqfull', 'RowGroup',group, 'TickLength', .3);
SHM1.draw();
SHM1.setRowName(rowName)
SHM1.setColName(colName1)
SHM1.setColLabelLocation('top')
SHM1.setXYTLim('XLim',[2.7,3.7], 'YLim',[0, 1], 'TLim',[-3*pi/2, pi/3]);
SHM1.Colorbar.Location = 'south';
SHM1.Colorbar.AxisLocation = 'in';

% set(SHM1.rowLabelHdl, 'Visible','off')
% set(SHM1.rowTickHdl, 'Visible','off')


% Set colormap 
colormap(ax1, slanCM(100, 32))
clim(ax1, clim1)


%% Circular heatmap 2
SHM2 = SHeatmap(ax2, Data2, 'Format','sqfull', 'RowGroup',group, 'TickLength', .3);
SHM2.draw();
SHM2.setRowName(rowName)
SHM2.setColName(colName2)
SHM2.setRowLabelLocation('right')
SHM2.setColLabelLocation('top')
% SHM2.setText()
SHM2.setXYTLim('XLim',[4, 5], 'YLim',[0, 1], 'TLim',[-3*pi/2, pi/3]);
SHM2.Colorbar.Location = 'south';

% Set colormap 
colormap(ax2, slanCM(97, 32))
clim(ax2, clim2)
% setTextPerpRadial(SHM2.textHdl)


%% Set position for colorbars and XYLim for axes
SHM1.Colorbar.Position = [.38, .55, .24, .02];
SHM2.Colorbar.Position = [.38, .45, .24, .02];
ax1.XLim = ax2.XLim;
ax1.YLim = ax2.YLim;

linkaxes([ax1, ax2], 'xy')