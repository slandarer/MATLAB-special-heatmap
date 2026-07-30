%% Group Sep with multilayer grouping block 

Data = rand(3, 16);
Class1 = [1,1,1,1, 2,2,2,2, 3,3,3,3, 4,4,4,4];
Class2 = [1,2,3,4, 1,2,3,4, 1,2,3,4, 1,2,3,4];
ClassName1 = {'AAAAA','BBBBB','CCCCC','DDDDD'};
ClassName2 = {'A1','A2','A3','A4','B1','B2','B3','B4','C1','C2','C3','C4','D1','D2','D3','D4'};
% Color (配色)
CList1 = [.70,.89,.80; .96,.81,.69; .85,.83,.85; .90,.81,.90];
CList2 = [.46,.42,.69; .62,.60,.78; .73,.74,.86; .85,.85,.92];

% create figure and axes (图窗及坐标区域创建)
fig = figure('Units','normalized', 'Position',[.05,.15,.72,.45]);
ax = axes('Parent',fig, 'Position',[.05,.15,.9,.85]);
% Draw Heatmap
SHM = SHeatmap(Data, 'Format','sq', 'Parent',ax, 'ColGroup',Class1);
SHM.RowName = compose('Row-%d', 1:3);
SHM.ColName = compose('Col-%d', 1:16);
SHM.draw().setFrame();
% Draw Block
[X1, Y1] = SClusterBlock(Class1, 'Orientation','top', 'BasePos',-.25, 'Height',.5, 'ColorList',CList1, 'Parent',ax, 'Group',Class1).draw();
[X2, Y2] = SClusterBlock(Class2, 'Orientation','top', 'BasePos',.25 , 'Height',.5, 'ColorList',CList2, 'Parent',ax, 'Group',Class1).draw();
% text
textProp = {'FontSize',17, 'HorizontalAlignment','center', 'FontName','Cambria'};
for i = 1:length(X1), text(ax, X1(i), Y1(i), ClassName1{i}, textProp{:}); end
for i = 1:length(X2), text(ax, X2(i), Y2(i), ClassName2{i}, textProp{:}); end

SHM.Colorbar.Location = 'southoutside';
SHM.Colorbar.Position = [.05, .1, .9, .04];

