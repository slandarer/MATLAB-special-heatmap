% GroupLabel
addpath('..\')
Data = rand(12, 12);

fig = figure('Units','normalized', 'Position',[.1,.1,.5,.8]);
ax = axes('Parent',fig, 'Position',[.15,.15,.7,.7]);


SHM = SHeatmap(ax, Data, 'Format','sq', 'GroupSep',.5);
SHM.RowName = compose('Y-%d', 1:12);
SHM.ColName = compose('X-%d', 1:12);
SHM.RowGroup = [1,1,1,1,1,1, 2,2,2,2, 3,3];
SHM.ColGroup = [1,1,1,1,1, 2,2,2,2,2,2,2];
SHM.draw()
SHM.setFrame()
SHM.setRowGroupName({'Group-Low', 'Group-Middle', 'Group-High'})
SHM.setColGroupName({'Group-Left', 'Group-Right'})

% SHM.setRowGroupLabel('FontWeight','bold', 'Color',[0,0,.8])
% SHM.setColGroupLabel('FontWeight','bold', 'Color',[.8,0,0])

% % try:
% SHM.setRowGroupLabelLocation('right')
% SHM.Colorbar.Position(1) = .05;
% SHM.setColGroupLabelLocation('top')



colormap(slanCM(53, 32))