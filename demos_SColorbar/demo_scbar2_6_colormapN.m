%% Heatmap with more than 2 colormaps (circ2_2)
addpath('..\')


rng(1)

Data = rand(80, 5);
rowName = compose('r-%d', 1:80);
colName = compose('c-%d', 1:5);
cmaps = {slanCM(8, 16), ...
         slanCM(9, 16), ...
         slanCM(10, 16), ...
         slanCM(11, 16), ...
         slanCM(12, 16)};
clims = {[0, 1], [0, 1], [0, 1], [0, 1], [0, 1]};

figure()
for i = 1:size(Data, 2)
    % Draw colormaps
    tSHM = SHeatmap(Data(:, i), 'Format','sqfull', 'TickLength',0).draw();
    tSHM.setRowName(rowName)
    tSHM.setColName(colName(i))
    tSHM.setRowLabelLocation('right')
    tSHM.setColLabelLocation('top')
    tSHM.setXYTLim('XLim', .5 + [0, .1] + (i - 1).*.2, 'YLim',[0,1], 'TLim',[-3*pi/2, 0])
    tSHM.setRowLabel('Visible','off')
    clim(clims{i})
    colormap(cmaps{i})
    tSHM.freezeColors()

    % Draw colorbars
    tcbar = SColorbar('Location','south', 'TickLength',0, ...
        'TickLabelOffset',.01, 'Tick', linspace(clims{i}(1), clims{i}(2), 3));
    tcbar.draw();
    tcbar.freezeColors
    tcbar.setXYTLim('XLim', [.2, 1.2], 'YLim', - (.5 + [0, .1] + (i - 1).*.2))
    tcbar.setTickLabel('HorizontalAlignment','center', 'VerticalAlignment','top', 'Rotation',0)
end

tSHM.setRowLabel('Visible','on')