%% Set heatmap to upper triangular or lower triangular type (show all types)

% Set to upper triangle or lower triangle (设置为上三角或下三角)


% Made up some data casually (随便捏造了点数据)
X=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,4)];
% Get the correlation matrix (求相关系数矩阵)
Data=corr(X);

% + 'triu'   : upper triangle                  : 上三角部分
% + 'tril'   : lower triangle                  : 下三角部分
% + 'triu0'  : upper triangle without diagonal : 扣除对角线上三角部分
% + 'tril0'  : lower triangle without diagonal : 扣除对角线下三角部分

Type={'triu','tril','triu0','tril0'};
for i=1:length(Type)
    figure()
    SHM_s1=SHeatmap(Data,'Format','sq');
    SHM_s1=SHM_s1.draw();
    SHM_s1.setText();
    % set Type (设置格式)
    SHM_s1.setType(Type{i});
%     exportgraphics(gca,['gallery\Type_',Type{i},'.png'])
end


%% Set variable labels' String (设置标签名称)
figure()
SHM_s2=SHeatmap(Data,'Format','sq');
SHM_s2=SHM_s2.draw();
SHM_s2.setType('tril');

varName={'A1','A2','A3','A4','A5','B1','B2','B3','B4','B5','C1','C2','C3','C4','C5'};
SHM_s2.setVarName(varName)
% exportgraphics(gca,'gallery\Type_labels.png')


%% Adjust the axis Limit to avoid occlusion (调整轴范围以避免遮挡)
figure()
SHM_s3=SHeatmap(Data,'Format','pie');
SHM_s3=SHM_s3.draw();
SHM_s3.setType('tril');
SHM_s3.setVarName({'Slandarer'})
ax=gca;
ax.XLim(2)=ax.XLim(2)+1;


%% show upper triangle of all formats (展示所有样式的上三角化)
Format={'sq','pie','donut','circ','bcirc','oval','hex','star','tril','triu','trilr','triul','asq','acirc'};
for i=1:length(Format)
    figure()
    SHM_s4=SHeatmap(Data,'Format',Format{i});
    SHM_s4=SHM_s4.draw();
    % set Type (设置格式)
    SHM_s4.setType('triu');
    exportgraphics(gca,['gallery\Type_triu_',Format{i},'.png'])
end

%% Set Font (设置标签字体)
figure()
SHM_s5=SHeatmap(Data,'Format','circ');
SHM_s5=SHM_s5.draw();
SHM_s5.setType('triu');
% Set Font Color (设置标签颜色)
SHM_s5.setRowLabel('Color',[.8,0,0])
SHM_s5.setColLabel('Color',[0,0,.8]) 
% exportgraphics(gca,'gallery\Type_Font.png')





