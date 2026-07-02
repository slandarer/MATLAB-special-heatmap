%% Change colormap for txt format heatmap

Data = rand([12, 12]) - .5;
figure()

SHM = SHeatmap(Data, 'Format','txt');
SHM.draw()

% For heatmaps of the 'txt' format, 
% it is necessary to use the setText
% to refresh the label colors after changing colormap
colormap(cool)
SHM.setText()
