%% Legend rotation
addpath('..\')

% Made up some data casually (随便捏造了点数据)
X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);
Data([107, 200]) = nan;
group = [1,1,1,1,1,1,2,2,2,2,2,3,3,3,3];

fig = figure('Units','normalized', 'Position',[.1,.05,.7,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
SHM = SHeatmap(Data, 'Format','c2rect');
SHM.RowGroup = group;
SHM.ColGroup = group;
SHM.draw();
SHM.setType('triu');
SHM.setColTickIndices([])

scbar = SColorbar('Location','east');
scbar.draw()

%% Draw cluster blocks (绘制聚类方块)
cg1 = {'Pos','Neg','Pos','Pos','Pos','Neg','Neg','Neg','Neg','Neg','Pos','Pos','Pos','Neg','Neg'};
CList1 = [.30,.60,.80; .80,.40,.40];
SCB1 = SClusterBlock(cg1, 'Orientation','top', 'BasePos',-.25 , 'Height',.5, ...
    'ColorList',CList1, 'Parent',ax, 'BlockProp',{'EdgeColor','k'}, 'Group',group);
SCB1.draw(); SCB1.setBox('Color','k', 'LineWidth',1);

% Add legend1 (添加图例1)
slgd1 = SLegend(SCB1, 'RowSep',.25, 'IconSize',[.6,.6], 'BasePos',[19,.5], 'TitleString','Detection');
slgd1.draw()


cg2 = {'spec-B','spec-B','spec-C','spec-A','spec-A','spec-C','spec-C','spec-B',...
    'spec-A','spec-A','spec-A','spec-B','spec-B','spec-A','spec-B'};
CList2 = [.52,.62,.47; .45,.57,.72; 1.0,.75,.45];
SCB2 = SClusterBlock(cg2, 'Orientation','top', 'BasePos',.25 , 'Height',.5, ...
    'ColorList',CList2, 'Parent',ax, 'BlockProp',{'EdgeColor','k'}, 'Group',group);
SCB2.draw(); SCB2.setBox('Color','k', 'LineWidth',1);

% Add legend1 (添加图例2)
% Order legend items by cnames2 (使图例按照 cnames2 的顺序展示)
cnames2 = {'spec-A','spec-B','spec-C'};
[~, ticks2] = intersect(SCB2.ClassName, cnames2);

slgd2 = SLegend(SCB2, 'RowSep',.25, 'IconSize',[.6,.6], 'BasePos',[19,4.5], 'TitleString','Species', ...
    'Tick',ticks2, 'Label',cnames2);
slgd2.draw()


% Set theta limits: TLim(1) == TLim(2) -> rotation only, no deformation (rotate by 45°)
% 设置角度范围：TLim(1) == TLim(2) -> 仅旋转不形变 (旋转45度)
SHM.setXYTLim('TLim', [pi/4, pi/4]);
scbar.setXYTLim('TLim', [pi/4, pi/4]);
SCB1.setXYTLim('TLim', [pi/4, pi/4]);
SCB2.setXYTLim('TLim', [pi/4, pi/4]);
slgd1.setXYTLim('TLim', [pi/4, pi/4]);
slgd2.setXYTLim('TLim', [pi/4, pi/4]);