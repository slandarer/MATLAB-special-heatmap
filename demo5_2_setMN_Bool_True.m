%% Decorative patch and text where the logical matrix Bool is true
rng(1)
figure()
Data = rand(9, 9); Data([4,5,13]) = nan;

SHM = SHeatmap(Data, 'Format','sq');
SHM.draw();
SHM.setText()

SHM.setText(Data >= .9, 'String','**', 'FontSize',20)         % Modify color of patches where Data >= 0.9 (修改 >= 0.9 方块颜色)
SHM.setPatch(Data >= .9, 'EdgeColor',[1,0,0], 'LineWidth',2)  % Set text where Data >= 0.9 to '**' (修改 >= 0.9 方块文本为**)
SHM.setPatch(isnan(Data), 'FaceColor',[.8,.6,.6])             % Modify color of NaN patches (修改 NaN 处颜色)