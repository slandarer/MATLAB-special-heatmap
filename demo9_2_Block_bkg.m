%% Block for bkg 

Data = rand([12, 12]) - .5;


figure(); ax = gca;

CList = [238,243,245; 255,255,255]./255;
SClusterBlock(ax, mod(1:size(Data, 1), 2), 'ColorList',CList ,...
    'Orientation','right', 'BasePos',.5, 'Height',size(Data, 2), 'BlockProp', {'EdgeColor','none'}).draw();

SHM = SHeatmap(Data, 'Format','star');
SHM.draw()
SHM.setFrame()
SHM.setBox('Visible','off')


clim([-.8, .8])
colormap(slanCM(97, 32))