%% Full-annular grouped heatmap

rng(2)
% Made up some data casually (随便捏造了点数据)
X1 = randn(20, 30) + [(linspace(-1,2.5,20)').*ones(1, 6), ...
                      (linspace(.5,-.7,20)').*ones(1, 4), ...
                      (linspace(.9,-.2,20)').*ones(1, 8), ...
                      (linspace(.2,-.1,20)').*ones(1, 12)];
X2 = randn(20,  4) +  (linspace(-1,2.5,20)').*ones(1, 4);
% Get the correlation matrix (求相关系数矩阵)
[Data, pval] = corr(X1, X2);
rowName = {'AS','AL','AA','AN','AD','AA2', 'BS','BL','BA','BN', ...
           'CS','CL','CA','CN','CD','CA2','CR','CE', ...
           'DS','DL','DA','DN','DD','DA2','DR','DE','DR2','DS2','DL2','DA3'};
colName = {'MA','PY','RLAN','NJAV'};
group = [1,1,1,1,1,1, 2,2,2,2, 3,3,3,3,3,3,3,3, 4,4,4,4,4,4,4,4,4,4,4,4];
gname = {'Group-A', 'Group-B', 'Group-C', 'Group-D'};
gsep1 = 1; gsep2 = .3; 

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.02,.02,.85,.96]);

GN = max(group); RN = size(Data, 1); CN = size(Data, 2);
GC = histcounts(group, .5:GN+.5); GR1 = GC + gsep1; GR2 = GC + gsep1 + gsep2;
CM = cumsum([0, GR2./sum(GR2)]);
for i = 1:GN
    tid = group == i; 
    % Draw heatmap (绘制热图)
    SHM = SHeatmap(ax, Data(tid, :), 'ColName',colName, 'RowName',rowName(tid), 'TickLength',0).draw();
    SHM.setText().setRowLabelLocation('right').setColLabelLocation('top')
    SHM.setRowLabel('FontSize',12).setColLabel('FontSize',12)
    SHM.setXYTLim('XLim',[1.2, 2], 'YLim',[0,1], 'TLim',pi - 2*pi*(CM(i) + gsep1./sum(GR2)) - 2*pi*[0, GC(i)./sum(GR2)])

    % Mark cells with p < 0.001 (black border)
    % 标记显著性 p < 0.001 的格子 (黑色边框)
    SHM.setPatch(pval(tid, :) < .001, 'EdgeColor',[0,0,0], 'LineWidth',1.5)

    % Draw group block (绘制分组方块)
    SCB = SClusterBlock(ax, 1, 'Orientation','left', 'ColorList',[1,1,1]);
    SCB.draw(); SCB.setXYTLim('XLim',[2.25, 2.45], 'YLim',[0,1], 'TLim',pi - 2*pi*CM(i) - 2*pi*[0, GR1(i)./sum(GR2)])

    % Manually reposition column labels (手动调整列标签的位置)
    for j = 1:length(SHM.colLabelHdl)
        tt = pi - 2*pi*(CM(i) + gsep1./sum(GR2)/2 - gsep2./sum(GR2)/2);
        rr = 1.2 + (j - .5)./CN.*.8;
        SHM.colLabelHdl(j).Position = [cos(tt).*rr, - sin(tt).*rr, 0];
    end
    % Add group name label (添加组名标签)
    gHdl = text(SCB.X, SCB.Y, gname{i}, 'FontSize',14, 'FontName','Times New Roman');
    % % Rotate all text labels to be perpendicular 
    % to the radial direction (调整所有文本垂直于径向)
    setTextPerpRadial(SHM.textHdl); 
    setTextPerpRadial(SHM.rowLabelHdl, 'outer')
    setTextPerpRadial(SHM.colLabelHdl)
    setTextPerpRadial(gHdl)
end

SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;