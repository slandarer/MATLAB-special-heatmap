%% Basic usage
addpath('..\')


Data = rand(10, 15) - .5;
colGroup = [1,1,1,1,1, 2,2,2,2,2,2, 3,3,3,3];


ax = gca;
SHM = SHeatmap(Data, 'Format','sqfull');
SHM.ColGroup = colGroup;
SHM.draw()

SHM.setFrame()
SHM.setBox('Color','w', 'LineWidth',.5)
SHM.setText()
set(SHM.frameHdl, 'Visible','off')


% Add colorbar (添加颜色条)
scbar = SColorbar(gca, 'Location','south', 'TickDir','out');
scbar.draw()
colormap(slanCM(97, 32))
clim([-.5, .5])

%% Draw cluster blocks (绘制聚类方块)
cg1 = {'Pos','Neg','Pos','Pos','Pos','Neg','Neg','Neg','Neg','Neg','Pos','Pos','Pos','Neg','Neg'};
CList1 = [.30,.60,.80; .80,.40,.40];
SCB1 = SClusterBlock(cg1, 'Orientation','top', 'BasePos',-.25 , 'Height',.5, ...
    'ColorList',CList1, 'Parent',ax, 'BlockProp',{'EdgeColor','k'}, 'Group',colGroup);
SCB1.draw(); SCB1.setBox('Color','w', 'LineWidth',.5);

% Add legend1 (添加图例1)
slgd1 = SLegend(SCB1, 'RowSep',.25, 'IconSize',[.6,.6], 'BasePos',[17,.5], 'TitleString','Detection');
slgd1.draw()





cg2 = {'spec-B','spec-B','spec-C','spec-A','spec-A','spec-C','spec-C','spec-B',...
       'spec-A','spec-A','spec-A','spec-B','spec-B','spec-A','spec-B'};
CList2 = [.52,.62,.47; .45,.57,.72; 1.0,.75,.45];
SCB2 = SClusterBlock(cg2, 'Orientation','top', 'BasePos',.25 , 'Height',.5, ...
    'ColorList',CList2, 'Parent',ax, 'BlockProp',{'EdgeColor','k'}, 'Group',colGroup);
SCB2.draw(); SCB2.setBox('Color','w', 'LineWidth',.5);

% Add legend1 (添加图例2)
% Order legend items by cnames2 (使图例按照 cnames2 的顺序展示)
cnames2 = {'spec-A','spec-B','spec-C'};
[~, ticks2] = intersect(SCB2.ClassName, cnames2);

slgd2 = SLegend(SCB2, 'RowSep',.25, 'IconSize',[.6,.6], 'BasePos',[17,4.5], 'TitleString','Species', ...
    'Tick',ticks2, 'Label',cnames2);
slgd2.draw()
