%% Heatmap with 2 colormaps (tri2_3)

addpath('..\')

% Made up some data casually (随便捏造了点数据)
rng(1)
Data1 = rand(10, 10);
Data2 = rand(10, 10).*100;
rowName = compose('R-%d', 1:10);
colName = compose('C-%d', 1:10);

fig = figure('Units','normalized', 'Position',[.1,.05,.7,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

% Draw heatmap 1
SHM1 = SHeatmap(ax, Data1, 'Format','triul').draw();
SHM1.setFrame()
SHM1.setRowLabel('Visible','off')
SHM1.setColLabel('Visible','off')
colormap(ax, slanCM(17, 16));
clim(ax, [0, 1])
SHM1.setText('Rotation', 45, 'FontSize',12)
SHM1.freezeColors()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','east', 'BasePos',size(Data1, 2) + .75, 'Width',.3);
scbar1.draw()
scbar1.freezeColors()

% Draw heatmap 2
SHM2 = SHeatmap(ax, Data2, 'Format','trilr', 'TickLabelOffset',.1).draw();
SHM2.setFrame()
SHM2.setBox('Color','k', 'LineWidth',1)
SHM2.setRowName(rowName)
SHM2.setColName(colName)
colormap(ax, slanCM(19, 16));
clim(ax, [0, 100])
SHM2.setText('Rotation', 45, 'FontSize',12)

% Add colorbar1 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','east', 'BasePos',size(Data1, 2) + 1.75, 'Width',.3);
scbar2.draw()

for i = 1:size(Data1, 1)
    for j = 1:size(Data1, 2)
        SHM1.textHdl(i, j).Position = SHM1.textHdl(i, j).Position - [1/6, 1/6, 0];
        SHM2.textHdl(i, j).Position = SHM2.textHdl(i, j).Position + [1/6, 1/6, 0];
    end
end