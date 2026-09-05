%% Colorbar rotation (GroupLabel 2)

addpath('..\')

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), ...
    (linspace(.5,-.7,20)').*ones(1, 3), ...
    (linspace(.9,-.2,20)').*ones(1, 6)];
% Get the correlation matrix (求相关系数矩阵)
[Data, pval] = corr(X);
names = {'A1','A2','A3','A4','A5','A6', 'B1','B2','B3', 'C1','C2','C3','C4','C5','C6'};
group = [1,1,1,1,1,1, 2,2,2, 3,3,3,3,3,3];
gname = {'Group-A','Group-B','Group-C'};


fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);


% Draw triangular heatmap (绘制三角热图)
SHM = SHeatmap(ax, Data, 'Format','sq', 'GroupLabelOffset',2, ...
    'RowGroup',group, 'ColGroup',group, 'VarName',names);
SHM.draw()
SHM.setType('tril')
SHM.setColLabelLocation('bottom')
SHM.setFrame()
SHM.setText().showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
SHM.setRowGroupName(gname)
SHM.setRowGroupLabelLocation('diag')

% Draw group block (绘制分组方块)
% Try : Format
%         ├── 'paren'  - Left/right parentheses (圆括号) ()
%         ├── 'brack'  - Left/right square brackets (方括号) []
%         ├── 'brace'  - Left/right curly braces (花括号) {}
%         ├── 'chev'   - Left/right angle brackets (尖括号) <>
%         ├── 'span'   - span markers (跨度标记) I
%         └── 'bounds' - Vertical bound markers (边界标记) =
SCB_T = SClusterBlock(ax, group, 'Orientation','top', 'Group',group, ...
    'BlockProp', {'EdgeColor','k', 'LineWidth',1.2}, 'Height',.5, 'BasePos',-1.5, 'Format','brace');
SCB_T.draw();
SCB_T.setXYTLim('XLim', sqrt(2)*SHM.XLim, 'TLim', [-pi/4, -pi/4]);

% Draw colorbar
RCB = SColorbar(ax, 'Location','north', 'CDir','reverse');
RCB.draw()
xl = sqrt(2)*diff(SHM.XLim);
RCB.setXYTLim('XLim', sqrt(2)/2 + xl.*.15 + .7.*[0, xl], 'YLim',[-.5, 0] - 4.5, 'TLim', [-pi/4, -pi/4]);