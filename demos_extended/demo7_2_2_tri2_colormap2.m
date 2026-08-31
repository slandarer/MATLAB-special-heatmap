%% Merge two triangle heatmaps with two colormaps (different CLim)
% 合并两个三角热图且使用不同 colormap (不同数据范围)
addpath('..\')
% Made up some data casually (随便捏造了点数据)
rng(1)
Data1 = rand(8, 8);
Data2 = rand(8, 8).*100;
rowName = compose('R-%d', 1:8);
colName = compose('C-%d', 1:8);

fig = figure('Units','normalized', 'Position',[.1,.05,.7,.7]);
ax1 = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
ax2 = axes('Parent',fig, 'Position',[.1,.1,.8,.8], 'Color','none');


% Draw heatmap 1
SHM1 = SHeatmap(ax1, Data1, 'Format','triul').draw();
SHM1.Colorbar.Position(1) = SHM1.Colorbar.Position(1) + .05;
SHM1.setFrame()
SHM1.setRowLabel('Visible','off')
SHM1.setColLabel('Visible','off')
SHM1.setText('FontSize',13)
colormap(ax1, slanCM(17, 32));
clim(ax1, [0, 1])

% Draw heatmap 2
SHM2 = SHeatmap(ax2, Data2, 'Format','trilr', 'TickLabelOffset',.1).draw();
SHM2.setFrame()
SHM2.setBox('Color','k', 'LineWidth',1)
SHM2.setRowName(rowName)
SHM2.setColName(colName)
SHM2.setText('FontSize',13)
SHM2.Colorbar.Position(1) = SHM2.Colorbar.Position(1) + .1;
colormap(ax2, slanCM(19, 32));
clim(ax2, [0, 100])

% Draw label for colorbars (为两个 colorbar 添加标签)
set(SHM1.Colorbar.Label, 'FontSize', 18, 'Position',[-1.5, 0, 0]);
set(SHM2.Colorbar.Label, 'FontSize', 18, 'Position',[-1.5, 0, 0]);


linkaxes([ax1, ax2], 'xy')
