%% Colormap

%% 调整clim(Adjust clim)
% 使用 clim() 或者 caxis() 调整颜色映射范围
% Use function clim() or caxis() to set the CLim
fig = figure('Position',[50,50,1400,700]);

% random data
Data = rand(12, 12) - .5; Data([4, 5, 13]) = nan;

% subplot1
ax1 = axes('Parent',fig, 'Position',[ 1/40, 0, 9/20, 1]);
SHM_ax1 = SHeatmap(Data, 'Format','sq', 'Parent',ax1).draw();
SHM_ax1.setText();

% subplot2 adjust clim
ax2 = axes('Parent',fig, 'Position',[21/40, 0, 9/20, 1]);
SHM_ax2 = SHeatmap(Data, 'Format','sq', 'Parent',ax2).draw();
clim([-.8, .8])
SHM_ax2.setText();

% exportgraphics(fig, 'gallery\Colormap_clim.png')

%% 使用MATLAB自带colormap (Use the built-in colormap in MATLAB)
figure()
Data = rand(14, 14);
SHM_Bone = SHeatmap(Data, 'Format','sq');
SHM_Bone.draw();
colormap(bone)
% exportgraphics(gca, 'gallery\Colormap_bone.png')

%% slanCM(slanCM colormap)
% Zhaoxu Liu / slandarer (2023). 200 colormap 
% (https://www.mathworks.com/matlabcentral/fileexchange/120088-200-colormap), 
% MATLAB Central File Exchange. 检索来源 2023/3/15.

% 单向colormap或离散colormap
for i = 20 % [20, 21, 61, 177]
    figure()
    Data = rand(14, 14);
    SHM_slan = SHeatmap(Data, 'Format','sq');
    SHM_slan.draw();
    colormap(slanCM(i))
    % exportgraphics(gca, ['gallery\Colormap_slanCM_', num2str(i), '.png'])
end
% 双向colormap (Diverging colormap)
for i = 141 % [141, 136, 134]
    figure()
    Data = rand(14, 14) - .5;
    SHM_slan = SHeatmap(Data, 'Format','sq');
    SHM_slan.draw();
    clim([-.7, .7])
    colormap(slanCM(i))
    SHM_slan.setText();
    % exportgraphics(gca, ['gallery\Colormap_slanCM_', num2str(i), '.png'])
end
