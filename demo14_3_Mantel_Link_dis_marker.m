%% Heatmap with Mantel test links - distance method and node marker

rng(3)
X1 = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
X2 = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];

group = ones(1, 15);
group(7:11) = 2;
group(12:15) = 3;

%% Figure and axes
fig = figure('Units','normalized', 'Position',[.05,.15,.72,.72]); 
ax = axes('Parent',fig, 'Position',[.06,.05,.88,.9]); 

[rho, pval] = corr(X1); rho(eye(size(rho)) == 1) = 0;
objHM = SHeatmap(ax, rho, 'Format','bcirc');
objHM.draw().setType('triu0');
objHM.setRowLabelLocation('right').setColLabelLocation('top')
objHM.setRowLabel('Visible','on').setColLabel('Visible','on')
delete(objHM.Colorbar)
set([objHM.rowLabelHdl, objHM.colLabelHdl], 'FontSize',14, 'FontName','Helvetica')


%% Draw mantel links
objML = SMantelLink(ax, X1, X2, 'Group',group);
objML.Layout = 'tril';
% Customize colors (自定义颜色)
objML.PColor = [68,147,56; 181,181,46; 224,224,224]./255;
objML.NodeColor1 = [74,89,162]./255;
objML.NodeColor2 = [74,89,162]./255;

% Set parameters for Mantel test (设置Mantel检验参数)
objML.NumPerm = 9999;                         % High permutation count for stable p-values (高置换次数以保证p值稳定)
objML.Distance1 = 'euclidean';                % Distance method for dataMat1 (第一个矩阵的距离方法)
objML.Distance2 = 'euclidean';                % Distance method for dataMat2 (第二个矩阵的距离方法)
objML.draw()

% Adjust legend and group label fonts (调整图例和组标签字体)
set(objML.legendTitleHdl, 'FontName','Helvetica')
set(objML.legendTickLabelHdl, 'FontSize',13, 'FontName','Helvetica')
set(objML.groupLabelHdl, 'FontSize',14, 'FontName','Helvetica')

% Change node markers to pentagrams (将节点标记改为五角星)
set([objML.node1Hdl, objML.node2Hdl], 'Marker','p', 'SizeData',300)
