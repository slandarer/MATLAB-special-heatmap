%% tiledlayout
figure('Units','normalized', 'Position',[.2,.2,.4,.6])
tiledlayout(2, 2)

nexttile
Data = rand(5, 5);
Data(randi([1, 25], [2, 1])) = nan;
SHeatmap(Data, 'Format','sq').draw()

nexttile
Data = rand(5, 5);
Data(randi([1, 25], [2, 1])) = nan;
SHeatmap(Data, 'Format','sq').draw()

nexttile
Data = rand(5, 5);
Data(randi([1, 25], [2, 1])) = nan;
SHeatmap(Data, 'Format','sq').draw()

nexttile
Data = rand(5, 5);
Data(randi([1, 25], [2, 1])) = nan;
SHeatmap(Data, 'Format','sq').draw()