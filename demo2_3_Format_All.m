%% Display all heatmap formats

% Preparation of various Format of heat maps (各类型热图绘制)
if ~exist('gallery\','dir')
    mkdir('gallery\')
end
% 'sq'          : square (default)          : 方形(默认)
% 'pie'         : pie chart                 : 饼图
% 'donut'       ：donut chart               : 环形饼图(甜甜圈图)
% 'circ'        : circular                  : 圆形
% 'bcirc'       : circle with box           : 有边框的圆形
% 'oval'        : oval                      : 椭圆形
% 'hex'         : hexagon                   ：六边形
% 'star'        : star                      : 五角星
% 'trill'(tril) : lower left triangle       : 下三角
% 'triur'(triu) : upper right triangle      : 上三角
% 'trilr'       : lower right triangle      : 右下三角
% 'triul'       : upper left triangle       : 左上三角
% 'asq'         : auto-size square          ：自带调整大小的方形
% 'acirc'       : auto-size circular        ：自带调整大小的圆形

Format={'sq','pie','donut','circ','bcirc','oval','hex','star','tril','triu','trilr','triul','asq','acirc'};
A=rand(12,12);
B=rand(12,12)-.5;

for i=1:length(Format)
    % Draw positive heat map (绘制纯正数热图)
    figure();
    SHM_A=SHeatmap(A,'Format',Format{i});
    SHM_A=SHM_A.draw();
    % exportgraphics(gca,['gallery\Format_',Format{i},'_A.png']) % 存储图片

    % Draw heat map with negative number (绘制含负数热图)
    figure();
    SHM_B=SHeatmap(B,'Format',Format{i});
    SHM_B=SHM_B.draw();
    % exportgraphics(gca,['gallery\Format_',Format{i},'_B.png']) % 存储图片
end
% close all