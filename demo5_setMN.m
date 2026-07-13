%% Decorative patch and text in row m and column n
% (修饰 m 行 n 列方块及文本)
rng(1)
figure()
Data = rand(9, 9); Data([4, 5, 13]) = nan;

SHM = SHeatmap(Data, 'Format','sq');
SHM.draw();

% Show Text (显示文本)
SHM.setText(); 


for i = 1:size(Data,1)
    for j = 1:size(Data,2)
        if Data(i, j) >= .9
            SHM.setText(i, j, 'String','**', 'FontSize',20)         % Modify color of patches where Data >= 0.9 (修改 >= 0.9 方块颜色)
            SHM.setPatch(i, j, 'EdgeColor',[1,0,0], 'LineWidth',2)  % Set text where Data >= 0.9 to '**' (修改 >= 0.9 方块文本为**)
        end
        if isnan(Data(i, j))
            SHM.setPatch(i, j, 'FaceColor',[.8,.6,.6])              % Modify color of NaN patches (修改 NaN 处颜色)
        end
    end
end