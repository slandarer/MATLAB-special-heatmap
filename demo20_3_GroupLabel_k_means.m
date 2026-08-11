%% GroupLabel for k-means clustering


% 随便生成一些随机数据 (Generate some random data arbitrarily)
rng(5)
Data = rand(50,10).*((1:10) + rand(1,10)) + randi([1,8],[50,1]);
Data = Data(:); Data = Data([end,1:end-1]); Data = reshape(Data, 50, []);

% 可以直接将上面部分删掉，然后 (You can delete the above part and then)
% Data = [] % 自己的数据 (your own data)

K = 6; % kmeans 分组数 (number of kmeans clusters)
CName = compose('Group-%d', 1:K);

% 将相同组数据放在一起，并计算相关矩阵 (Group data by cluster and compute correlation matrix)
[Class, Ind] = sort(kmeans(Data, K));
HMat = corr(Data(Ind,:).');

% 绘制热图 (Draw heatmap)
SHM = SHeatmap(HMat, 'RowGroup',Class, 'ColGroup',Class, ...
    'GroupLabelOffset',1, 'TickLength',0);
SHM.draw()
SHM.setFrame('LineWidth',1.5)
SHM.setRowLabel('Visible','off')
SHM.setColLabel('Visible','off')

SHM.setRowGroupName(CName)
SHM.setColGroupName(CName)
SHM.setRowGroupLabel('Rotation',0, 'HorizontalAlignment','right')
SHM.setColGroupLabel('Rotation',25, 'HorizontalAlignment','right')


title('K-Means Clustering Heatmap', 'FontSize',25)
