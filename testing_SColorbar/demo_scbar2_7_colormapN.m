%% Heatmap with more than 2 colormaps (table_1)
addpath('..\')


Data = rand([12, 25]);
group = [ones(1, 5).*1, ones(1, 5).*2, ones(1, 5).*3, ones(1, 7).*4, ones(1, 3).*5];
Data(:, group == 4) = Data(:, group == 4) - .5;

gnames = {'Group-A','Group-B','Group-C','Group-D','Group-E'};
rnames = compose('Row-%d', 1:12);
cnames = compose('Col-%d', 1:25);
formats = {'c2rect', 'c2rect', 'barh', 'c2rect', 'teardrop'};

% Colormaps and clims
cmaps = {slanCM(19, 32), ...
         slanCM(21, 32), ...
         flipud(slanCM(53, 32)), ...
         interp1([0,.5,1], [173,208,53; 255,255,255; 252,137,180]./255, linspace(0,1,32)), ...
         interp1([0,1], [255,255,255; 79,148,204]./255, linspace(0,1,32))};
clims = {[0, 1], [0, 1], [0, 1], [-.5,.5], [0, 1]};


fig = figure('Units','normalized', 'Position',[.05,.1,.9,.7]);
ax = axes('Parent',fig, 'Position',[.05,.1,.9,.85]);

% Draw background shading
SClusterBlock(ax, mod(1:size(Data, 1), 2), 'ColorList',[.95,.95,.95; 1,1,1], ...
    'Orientation','right', 'BasePos',.5, 'Height',size(Data, 2) + max(group) - 1, ...
    'BlockProp', {'EdgeColor','none'}).draw();

% Draw heatmaps
for i = 1:max(group)
    ind = find(group == i);
    xl = [ind(1) - .5, ind(end) + .5] + (i - 1);
    tSHM = SHeatmap(ax, Data(:, ind), 'Format', formats{i}, ...
        'RowName',rnames, 'ColName',cnames(ind)).draw();
    if i ~= 1
        tSHM.setType('col')
        tSHM.setColLabelLocation('bottom')
    end
    tSHM.setXYTLim('XLim', xl)
    tSHM.setColLabel('Rotation', 30)
    tSHM.setColGroupName(gnames(i))

    % Set colormap and clim
    clim(clims{i})
    colormap(cmaps{i})
    tSHM.freezeColors()

    % Draw colorbars
    tcbar = SColorbar('Location','north', 'TickLength',.1, ...
        'TickLabelOffset',.01, 'Tick', linspace(clims{i}(1), clims{i}(2), 3));
    tcbar.draw();
    tcbar.freezeColors
    tcbar.setXYTLim('XLim',xl, 'YLim',[0, -.5])
    tcbar.setTickLabel('HorizontalAlignment','center', 'VerticalAlignment','bottom', 'Rotation',0)
end