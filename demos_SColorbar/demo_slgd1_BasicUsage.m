%% Basic usage
addpath('..\')

Data = rand(12, 12) - .5;
SHM = SHeatmap(Data, 'Format','moon');
SHM.draw()
SHM.setFrame()

% Add colorbar (添加颜色条)
scbar = SColorbar(gca, 'Location','east');
scbar.draw()


% Add legend1 (添加图例1)
slgd1 = SLegend(SHM, 'Location','southeast', 'RowSep',0);
slgd1.draw()

% Add legend2 (添加图例2)
slgd2 = SLegend(SHM, 'BasePos',[14.6, .5], 'ColNum',2, 'RowSep',.25, 'TickLength',.1, ...
    'Tick', [.3,.2,.1,-.1,-.2,-.3], 'Label',{'Pos-3','Pos-2','Pos-1','Neg-1','Neg-2','Neg-3'});
slgd2.draw()


% Add legend3 (添加图例3)
slgd3 = SLegend(SHM, 'BasePos',[14.6, 6], 'ColNum',3, 'Tick',[-.4,0,.4], 'ColSep',1.5, 'TickLength',.1);
slgd3.draw()

cmap = interp1([0,.5,1], [173,208,53; 255,255,255; 252,137,180]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)