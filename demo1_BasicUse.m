%% Basic usage

% Basic usage (基础使用)
if ~exist('gallery\','dir')
    mkdir('gallery\')
end

%% Draw positive heatmap (绘制无负数的热图)
figure()
Data = rand(15, 15);
SHM1 = SHeatmap(Data, 'Format','sq');
SHM1.draw();

drawnow
% exportgraphics(gca, 'gallery\Basic_positive.png')

%% Contains negative numbers (绘制有负数热图)
figure()
Data = rand(15,15) - .5;
SHM2 = SHeatmap(Data, 'Format','sq');
SHM2.draw();

drawnow
% exportgraphics(gca, 'gallery\Basic_negative.png')

%% Draw heatmaps of different sizes (绘制不同大小热图)
figure()
Data = rand(25, 30);
SHM3 = SHeatmap(Data, 'Format','sq');
SHM3.draw();

drawnow
% exportgraphics(gca, 'gallery\Basic_25_30.png')

%% Adjust the colorbar Location (调整colorbar位置)
figure()
Data = rand(3,12);
SHM4 = SHeatmap(Data, 'Format','sq');
SHM4.draw();
CB = colorbar;
CB.Location = 'southoutside';

drawnow
% exportgraphics(gca, 'gallery\Basic_colorbar_location.png')

%% Draw heatmap with NaN (绘制有NaN热图)
figure()
Data = rand(12, 12) - .5;
Data([4, 5, 13]) = nan;
SHM5 = SHeatmap(Data, 'Format','sq');
SHM5.draw();

drawnow
% exportgraphics(gca, 'gallery\Basic_with_NaN.png')

%% Draw heatmap with texts (绘制有文本热图)
figure()
Data = rand(12, 12) - .5;
Data([4, 5, 13]) = nan;
SHM6 = SHeatmap(Data, 'Format','sq');
SHM6.draw();
SHM6.setText();

drawnow
% exportgraphics(gca, 'gallery\Basic_with_text.png')

%% Draw heatmap with labels by XTick and YTick (绘制带标签热图, 使用 axes 原本的 XY 刻度)
figure()
Data = rand(12, 12);
SHM7 = SHeatmap(Data, 'Format','sq');
SHM7.draw(); 
SHM7.ax.XTickLabel = {'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10','X-11','X-12'};
SHM7.ax.YTickLabel = {'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10','Y-11','Y-12'};

drawnow

%% Draw heatmap with labels by RowName and ColName (绘制带标签热图, 使用 SHeatmap 的行列标签功能)
figure()
Data = rand(12, 12);
SHM8 = SHeatmap(Data, 'Format','sq');
SHM8.ColName = {'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10','X-11','X-12'};
SHM8.RowName = {'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10','Y-11','Y-12'};
SHM8.draw(); 
SHM8.setFrame()

drawnow
% exportgraphics(gca, 'gallery\Basic_with_labels.png')