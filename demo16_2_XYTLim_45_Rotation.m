%% Rotated triangular heatmap (45° rotation)

% Rotation without deformation is currently supported only for the following formats: 
% 'sq', 'asq', 'circ', 'acirc', and 'bcirc'.

% Made up some data casually (随便捏造了点数据)
X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);
Data([107, 200]) = nan;


figure()
SHM = SHeatmap(Data, 'Format','circ');
SHM.RowGroup = [1,1,1,1,1,1,2,2,2,2,2,3,3,3,3];
SHM.ColGroup = [1,1,1,1,1,1,2,2,2,2,2,3,3,3,3];
SHM.draw();
SHM.setType('triu0');


% Set theta limits: TLim(1) == TLim(2) -> rotation only, no deformation (rotate by 45°)
% 设置角度范围：TLim(1) == TLim(2) -> 仅旋转不形变 (旋转45度)
SHM.setXYTLim('TLim', [pi/4, pi/4]);

% Adjusting label angles and colorbar position (调整标签角度及 colorbar 位置)
SHM.setColLabel('Rotation',0, 'HorizontalAlignment','right')
SHM.setRowLabel('Rotation',45)
SHM.Colorbar.Location = 'southoutside';

