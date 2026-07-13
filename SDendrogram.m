function [order, obj] = SDendrogram(Data, varargin)
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
obj.arginList = {'Orientation', 'Parent', 'Method', 'BasePos', 'Height'};
obj.Orientation = 'top';
obj.Parent = gca;
obj.DataLen = 0;
obj.Method = 'average';
obj.Height = 1;
obj.BasePos = 0;

% Parse input arguments (解析输入参数)
for i = 1:2:(length(varargin) - 1)
    tid = ismember(lower(obj.arginList), lower(varargin{i}));
    if any(tid)
        obj.(obj.arginList{tid}) = varargin{i + 1};
    end
end
obj.Parent.XColor = 'none';
obj.Parent.YColor = 'none';
obj.Parent.XTick = [];
obj.Parent.YTick = [];
obj.Parent.YDir = 'reverse';
obj.Parent.NextPlot = 'add';

fig = figure(); ax = axes('Parent',fig);

% Compute linkage (计算链接矩阵)
if isequal(obj.Orientation, 'top')
    tree = linkage(Data.', obj.Method);
else
    tree = linkage(Data  , obj.Method);
end

% Draw dendrogram (绘制树状图)
[treeHdl, ~, order] = dendrogram(ax, tree, 0, 'Orientation', obj.Orientation);

minX = 0; maxX = 0; minY = 0; maxY = 0;
for i = 1:length(treeHdl)
    minX = min(minX, min(treeHdl(i).XData));
    maxX = max(maxX, max(treeHdl(i).XData));
    minY = min(minY, min(treeHdl(i).YData));
    maxY = max(maxY, max(treeHdl(i).YData));
end

obj.TreeHdl = gobjects(1, length(treeHdl));
for i = 1:length(treeHdl)
    X = treeHdl(i).XData; 
    Y = treeHdl(i).YData;
    switch obj.Orientation
        case 'top'
            Y = (Y - minY)./(maxY - minY).*(- obj.Height) + obj.BasePos;
        case 'left'
            X = (X - minX)./(maxX - minX).*(- obj.Height) + obj.BasePos;
    end
    obj.TreeHdl(i) = plot(obj.Parent, X, Y, 'Color',[0,0,0], 'LineWidth',1);
end
delete(fig);

axis(obj.Parent, 'tight');
% Set axis limits (设置坐标轴范围)
switch obj.Orientation
    case 'top'
        obj.DataLen = size(Data, 2);
        tLim = [1, obj.DataLen] + [-0.5, 0.5];
        obj.Parent.XLim(1) = min(obj.Parent.XLim(1), tLim(1));
        obj.Parent.XLim(2) = max(obj.Parent.XLim(2), tLim(2));
    case 'left'
        obj.DataLen = size(Data, 1);
        tLim = [1, obj.DataLen] + [-0.5, 0.5];
        obj.Parent.YLim(1) = min(obj.Parent.YLim(1), tLim(1));
        obj.Parent.YLim(2) = max(obj.Parent.YLim(2), tLim(2));
end
end