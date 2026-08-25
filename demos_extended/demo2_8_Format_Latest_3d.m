%% Latest format - 3d
addpath('..\')

figure()

rng(1)
Data = rand(9, 9);
SHM = SHeatmap(Data, 'Format','3d', 'GroupSep',1, 'Format3DTheta',pi/3.5, 'Format3DHeight',2);
SHM.RowGroup = [1,1,2,2,2,2,3,3,3];
SHM.ColGroup = [1,1,2,2,2,2,3,3,3];
SHM.draw();


% SHM.setType('tril')
% SHM.setColLabelLocation('bottom')
% SHM.setFrame()

