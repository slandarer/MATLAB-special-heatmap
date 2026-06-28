function order = SDendrogram(Data, varargin)
% SDendrogram - Draw dendrogram and return leaf order
%   order = SDendrogram(Data) draws top-oriented dendrogram with average linkage
%
%   order = SDendrogram(Data, 'Orientation', ori) specifies orientation:
%       'top'  - horizontal dendrogram (default)
%       'left' - vertical dendrogram
%
%   order = SDendrogram(Data, 'Parent', ax) draws in specified axes
%
%   order = SDendrogram(Data, 'Method', method) linkage method (default: 'average')


% =========================================================================
% Zhaoxu Liu / slandarer (2023). special heatmap
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap),
% MATLAB Central File Exchange. Retrieved March 1, 2023.
% =========================================================================

% Parameter definition (参数定义)
obj.arginList = {'Orientation', 'Parent', 'Method'};
obj.Orientation = 'top';
obj.Parent = gca;
obj.DataLen = 0;
obj.Method = 'average';

% Parse input arguments (解析输入参数)
for i = 1:2:(length(varargin) - 1)
    tid = ismember(obj.arginList, varargin{i});
    if any(tid)
        obj.(obj.arginList{tid}) = varargin{i + 1};
    end
end

figure();

% Compute linkage (计算链接矩阵)
if isequal(obj.Orientation, 'top')
    tree = linkage(Data.', obj.Method);
else
    tree = linkage(Data, obj.Method);
end

% Draw dendrogram (绘制树状图)
[treeHdl, ~, order] = dendrogram(tree, 0, 'Orientation', obj.Orientation);
set(treeHdl, 'Color', [0, 0, 0], 'LineWidth', 0.8);

% Copy to target axes (复制到目标坐标区)
tempFig = treeHdl(1).Parent.Parent;
axTree = copyAxes(tempFig, 1, obj.Parent);
axTree.XColor = 'none';
axTree.YColor = 'none';
axTree.XTick = [];
axTree.YTick = [];
axTree.NextPlot = 'add';
delete(tempFig);

% Set axis limits (设置坐标轴范围)
switch obj.Orientation
    case 'top'
        obj.DataLen = size(Data, 2);
        axTree.XLim = [1, obj.DataLen] + [-0.5, 0.5];
    case 'left'
        obj.DataLen = size(Data, 1);
        axTree.YDir = 'reverse';
        axTree.YLim = [1, obj.DataLen] + [-0.5, 0.5];
end

% ---------------------------------------------------------------------
    function axbag = copyAxes(fig, k, newAx)
        % Copy axes object from source figure to target parent
        % @author : slandarer
        % 公众号  : slandarer随笔
        % 知乎    : slandarer
        %
        % 此段代码解析详见公众号 slandarer随笔 文章：
        %《MATLAB | 如何复制figure图窗任意axes的全部信息？》
        % https://mp.weixin.qq.com/s/3i8C78pv6Ok1cmEZYPMyWg

        classList = ismember(1:length(fig.Children), ...
            find(cellfun(@(x) isa(x, 'matlab.graphics.axis.Axes'), ...
            num2cell(fig.Children))));
        isaaxes = find(classList);
        oriAx = fig.Children(isaaxes(end - k + 1));

        if isaaxes(end - k + 1) - 1 < 1 || ...
                isa(fig.Children(isaaxes(end - k + 1) - 1), 'matlab.graphics.axis.Axes')
            oriLgd = [];
        else
            oriLgd = fig.Children(isaaxes(end - k + 1) - 1);
        end

        axbag = copyobj([oriAx, oriLgd], newAx.Parent);
        axbag(1).Position = newAx.Position;
        delete(newAx);
    end
end