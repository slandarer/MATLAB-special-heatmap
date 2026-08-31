%% Legend


Data = randi([1, 5], [8, 5]);
colors = [.75,.38,.42; .82,.53,.44; .92,.80,.55; .64,.75,.55; .71,.56,.68];
rnames = compose('row-%d', 1:8);
cnames = compose('col-%d', 1:5);
gnames = compose('group-%d', 1:5);


SHM = SHeatmap(Data, 'Format','rrect', 'RowName',rnames, 'ColName',cnames, 'TickLabelOffset',.05);
SHM.draw()
SHM.setFrame('Visible','off')


clim([1, 5])
colormap(colors)
delete(SHM.Colorbar)


[~, tind] = unique(Data);
legend(SHM.patchHdl(tind), gnames, 'FontSize',15, 'Location','northeastoutside')
