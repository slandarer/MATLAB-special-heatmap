addpath('..'); 

Data = rand(5, 30);
cinf = {summer(32); ...
        summer(32); ...
        slanCM(7, 32); ...
        slanCM(19, 32); ...
        [107,174,214; 250,159,181]./255};

for i = 1:size(Data, 1)
    SHM = SHeatmap(Data(i, :), 'RowName',{'1'}).draw();
    SHM.setBox('LineWidth',1, 'Color','k').setType('row')
    SHM.setXYTLim('XLim',[0, 25], 'YLim', (i - 1)*1.5 + [0, 1])

    colormap(cinf{i});
    clim([min(Data(i, :)), max(Data(i, :))])

    SHM.freezeColors(); delete(SHM.Colorbar)
end