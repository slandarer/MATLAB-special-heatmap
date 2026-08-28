%% Set heatmap format

A = rand(12, 12);
B = rand(12, 12) - .5;

% Draw heatmap with all number positive (绘制纯正数热图)
figure();
SHM_A = SHeatmap(A, 'Format','c2rect');
SHM_A.draw()

% Draw heatmap with negative number (绘制含负数热图)
figure();
SHM_B = SHeatmap(B, 'Format','shade');
SHM_B.draw()

% 'sq'          : square (default)          : 方形 (默认)
% 'sqfull'      : square (full-size)        : 方形 (满格)
% 'shade'       : Square (neg-values shaded): 方形 (负数部分阴影填充)
% 'rrect'       : rounded rectangle         : 圆角矩形
% 'c2rect'      : circle to rectangle       : 圆形到矩形过度
% 'pie'         : pie chart                 : 饼图
% 'donut'       : donut chart               : 环形饼图 (甜甜圈图)
% 'circ'        : circle                    : 圆形
% 'bcirc'       : circle with box           : 有边框的圆形
% 'oval'        : oval                      : 椭圆形
% 'hex'         : hexagon                   ：六边形
% 'star'        : star                      : 五角星
% 'moon'        : moon                      : 月亮
% 'arrow'       : arrow                     : 箭头
% 'teardrop'    : teardrop                  : 水滴状
% 'bar'         : bar graph                 : 柱状图
% 'barh'        : Horizontal bar graph      : 水平柱状图
% 'trill'(tril) : lower left triangle       : 下三角
% 'triur'(triu) : upper right triangle      : 上三角
% 'trilr'       : lower right triangle      : 右下三角
% 'triul'       : upper left triangle       : 左上三角
% 'asq'         : auto-size square          ：自带调整大小的方形
% 'acirc'       : auto-size circular        ：自带调整大小的圆形
% 'arrect'      : auto-size rounded rect    : 自带调整大小的圆角矩形
% 'txt'(text)   : colored text              : 带颜色的文本
% '3d'          : 3D bar                    : 三维柱状图
% 'cust'        : custom shape              : 自定义形状
% 'acust'       : auto-size custom shape    : 自带调整大小的自定义形状