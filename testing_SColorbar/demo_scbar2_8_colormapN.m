%% Heatmap with more than 2 colormaps (table_2)
addpath('..\')

Data = rand([20, 15]);
group = [ones(1, 5).*1, ones(1, 5).*2, ones(1, 7).*3, ones(1, 3).*4];
Data(group == 3, :) = Data(group == 3, :) - .5;


gnames = {'Group-A','Group-B','Group-C','Group-D','Group-E'};
rnames = compose('Row-%d', 1:20);
cnames = compose('Col-%d', 1:15);
formats = {'c2rect' 'barh', 'c2rect', 'teardrop'};

% Colormaps and clims
cmaps = {slanCM(19, 32), ...
         flipud(slanCM(53, 32)), ...
         interp1([0,.5,1], [173,208,53; 255,255,255; 252,137,180]./255, linspace(0,1,32)), ...
         interp1([0,1], [255,255,255; 79,148,204]./255, linspace(0,1,32))};
clims = {[0, 1], [0, 1], [-.5,.5], [0, 1]};

fig = figure('Units','normalized', 'Position',[.05,.05,.5,.9]);
ax = axes('Parent',fig, 'Position',[.15,.05,.8,.9]);

% Draw background shading
SClusterBlock(ax, mod(1:size(Data, 2), 2), 'ColorList',[.95,.95,.95; 1,1,1], ...
    'Orientation','bottom', 'BasePos',.5, 'Height',size(Data, 1) + max(group) - 1, ...
    'BlockProp', {'EdgeColor','none'}).draw();


% Draw heatmaps
for i = 1:max(group)
    ind = find(group == i);
    yl = [ind(1) - .5, ind(end) + .5] + (i - 1);
    tSHM = SHeatmap(ax, Data(ind, :), 'Format', formats{i}, ...
        'RowName',rnames(ind), 'ColName',cnames, 'GroupLabelOffset',2.5).draw();
    
    if i ~= max(group)
        tSHM.setType('row')
    end

    tSHM.setXYTLim('YLim', yl)
    tSHM.setRowGroupName(gnames(i))
    tSHM.setRowGroupLabel('Rotation',90)

    % Set colormap and clim
    clim(clims{i})
    colormap(cmaps{i})
    tSHM.freezeColors()

    % Draw colorbars
    tcbar = SColorbar('Location','east', 'TickLength',.1, ...
        'TickLabelOffset',.05, 'Tick', linspace(clims{i}(1), clims{i}(2), 3));
    tcbar.draw();
    tcbar.freezeColors
    tcbar.setXYTLim('XLim',size(Data, 2) + .75 + [0, .5], 'YLim',yl)
end

tSHM.setColLabel('Rotation',30)
ax.YLim(1) = .25;
title(ax, 'Table Heatmap by SHeatmap', 'FontSize',21)