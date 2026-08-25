%% Latest format - rrect
addpath('..\')

fig = figure('Units','normalized', 'Position',[.1,.2,.7,.6]);
axT = axes('Parent',fig, 'Position',[.15, .55, .75, .4]);
axB = axes('Parent',fig, 'Position',[.15, .15, .75, .4]);

% Define column group assignment (定义列分组标签)
group = [1,1,1,1,1,1,1,1, 2,2,2,2,2,2,2,2];
% Row and column names (行列名称)
rowName = {'RL-SL','RL2SSX','RL3XX-DYH','RL4GTXYKN'};
colName = {'CLAS','CLALXXX','CLAA','CLAN','CLAD','CLAA2', ...
           'CLBS','CLBLXYZT','CLBACLASS','CLBNMNSZ', ...
           'CLCS','CLCL','CLCA','CLCN-5126','CLCD-C-131','CLCA2-C-137'};
DataT = rand([4, 16]) - .5;
DataB = rand([4, 16]) - .5;

% Top heatmap (上方热图)
SHM_T = SHeatmap(axT, DataT, 'Format','rrect', 'ColGroup',group, 'GroupLabelOffset',.5);
SHM_T.draw()
SHM_T.setType('row')
SHM_T.setFrame('Visible','off')
SHM_T.setRowName(rowName)
SHM_T.setColGroupName({'Group-L', 'Group-R'})
SHM_T.setColGroupLabelLocation('top')
cmapT = interp1([0,.5,1], [60,81,91; 255,255,255; 79,148,204]./255, linspace(0,1,32));
colormap(axT, cmapT)

% Bottom heatmap (下方热图)
SHM_B = SHeatmap(axB, DataB, 'Format','rrect', 'ColGroup',group);
SHM_B.draw()
SHM_B.setFrame('Visible','off')
SHM_B.setColName(colName)
SHM_B.setRowName(rowName)
cmapB = interp1([0,.5,1], [173,208,53; 255,255,255; 252,137,180]./255, linspace(0,1,32));
colormap(axB, cmapB)

% Synchronize axes and colorbar positions (同步坐标轴和颜色条位置)
SHM_T.ax.YLim = SHM_B.ax.YLim;
SHM_T.Colorbar.Position = [.92, .585, .02, .34];
SHM_B.Colorbar.Position = [.92, .185, .02, .34];