%% Heatmap with 2 colormaps (tri2_4)

addpath('..\')

% Made up some data casually (随便捏造了点数据)
rng(1)
Data1 = rand(9, 9);
Data2 = rand(9, 9).*100;
rowName = compose('R-%d', 1:9);
colName = compose('C-%d', 1:9);

fig = figure('Units','normalized', 'Position',[.1,.05,.7,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

% Draw heatmap 1
SHM1 = SHeatmap(ax, Data1, 'Format','triu').draw();
SHM1.setFrame()
SHM1.setRowLabel('Visible','off')
SHM1.setColLabel('Visible','off')
SHM1.setText('FontSize',12)
colormap(ax, slanCM(17, 16));
clim(ax, [0, 1])
SHM1.freezeColors()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','northeast', 'BasePos',size(Data1, 2) + .75, 'Width',.4);
scbar1.draw()
scbar1.freezeColors()

% Draw heatmap 2
SHM2 = SHeatmap(ax, Data2, 'Format','tril', 'TickLabelOffset',.1).draw();
SHM2.setFrame()
SHM2.setBox('Color','k', 'LineWidth',1)
SHM2.setRowName(rowName)
SHM2.setColName(colName)
SHM2.setText('FontSize',12)
colormap(ax, slanCM(19, 16));
clim(ax, [0, 100])

% Add colorbar1 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','southeast', 'BasePos',size(Data1, 2) + .75, 'Width',.4);
scbar2.draw()
