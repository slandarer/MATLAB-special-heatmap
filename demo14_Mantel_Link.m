%% Heatmap with Mantel test links

rng(7)
%% Load data (加载数据)
load('lichenData.mat')                      % Load pre-saved data package (加载预存的数据包)
Data1 = varechem.Variables;                 % Environmental matrix (环境因子矩阵)
Data2 = varespec.Variables;                 % Species composition matrix (物种组成矩阵)
labels = varechem.Properties.VariableNames; % Environmental variable names (环境变量名称)

% Define species groups: 44 columns into 4 groups (将44个物种列分为4组)
groupName = {'Spec01', 'Spec02', 'Spec03', 'Spec04'};
group = zeros(1, size(Data2, 2));
group(1:7) = 1;    % Group 1: columns 1-7 (第1组：列1-7)
group(8:18) = 2;   % Group 2: columns 8-18 (第2组：列8-18)
group(19:37) = 3;  % Group 3: columns 19-37 (第3组：列19-37)
group(38:44) = 4;  % Group 4: columns 38-44 (第4组：列38-44)

%% Figure and axes
fig = figure('Units','normalized', 'Position',[.05,.15,.72,.72]); 
ax = axes('Parent',fig, 'Position',[.06,.05,.88,.9]); 

%% Draw heatmap
[rho, pval] = corr(Data1);
objHM = SHeatmap(ax, rho, 'Format','sq').draw();
% Display significance stars: p < 0.05 *, p < 0.01 **, p < 0.001 *** 
objHM.setText().showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
objHM.setVarName(labels).setType('linkl')

%% Draw mantel links
% Create Mantel link object with env data, species data and groups (创建Mantel链接对象，传入环境数据、物种数据及分组信息)
objML = SMantelLink(ax, Data1, Data2, 'Group',group);
objML.GroupName = groupName;          % Set group names (设置组名)
objML.LegendLocation = 'west';        % Place legend on the left (图例置于左侧)
objML.Layout = 'triu';                % Links placed in upper triangle (链接采用上三角布局)
% objML.Curvature = -1/3;
% objML.LinkBendMode = 'simple';
% objML.NumPerm = 9999;
objML.draw() 






