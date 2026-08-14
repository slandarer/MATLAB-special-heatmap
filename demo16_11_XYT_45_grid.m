%% Rotated triangular heatmap (45° rotation) with grid

% Rotation without deformation is currently supported only for the following formats: 
% 'sq', 'asq', 'circ', 'acirc', 'bcirc', 'cust', 'rrect', 'acust', 'c2rect', and 'arrect'

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

figure()
SHM = SHeatmap(Data, 'Format','acirc', 'TickLength',0, 'TickLabelOffset', 0);
SHM.draw();
SHM.setType('triu0');
SHM.setPatch('EdgeColor','k')
SHM.setBox('Visible','off')
SHM.setGrid()


% Set theta limits: TLim(1) == TLim(2) -> rotation only, no deformation (rotate by 45°)
% 设置角度范围：TLim(1) == TLim(2) -> 仅旋转不形变 (旋转45度)
SHM.setXYTLim('TLim', [pi/4, pi/4]);
SHM.setFrame('Visible','off')

SHM.Colorbar.Location = 'southoutside';
SHM.ax.YLim(2) = .5;
colormap(slanCM(97, 32))


