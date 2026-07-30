classdef SDendrogram < handle
% SDendrogram - Create and customize dendrogram
%   SD = SDendrogram(Data); Creates top-oriented dendrogram object with average linkage
%   创建顶部方向、使用平均连接的树状图对象。
%
%   SD = SDendrogram(Data, 'Orientation', ori); specifies orientation 指定方向：
%       'top'  - horizontal dendrogram (default) (水平树状图，默认)
%       'left' - vertical dendrogram (垂直树状图)
%
%   SD = SDendrogram(Data, 'Parent', ax); 
%   SD = SDendrogram(ax, Data); Creates in specified axes.
%   在指定坐标区中创建。
%
%   SD = SDendrogram(Data, 'Method', method); linkage method (default: 'average').
%   连接方法 (默认: 'average')。
%
%   SD = SDendrogram(___, propName, propVal); specifies property name-value
%   pairs when creating the object.
%   创建对象时指定属性名-属性值对。
%
%   SD.propName = propVal; sets properties before calling draw().
%   在调用 draw() 前设置属性。
%
%   [order, group] = SD.draw(); renders the dendrogram.
%   渲染树状图。
%
% Parameters:
%   'Orientation'   - 'top' (default) or 'left'
%                     树状图方向，'top' (默认) 或 'left'
%   'BasePos'       - Base position for dendrogram placement (default: 0)
%                     树状图放置的基准位置 (默认: 0)
%   'Height'        - Height of dendrogram
%                     树状图高度
%   'Method'        - Linkage method (default: 'average')
%                     层次聚类连接方法 (默认: 'average')
%   'MaxClust'      - Maximum number of clusters
%                     最大聚类数
%   'GroupSep'      - Group separation gap
%                     组间分离间距

% =========================================================================
% Zhaoxu Liu / slandarer (2023). special heatmap
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap),
% MATLAB Central File Exchange. Retrieved March 1, 2023.
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). STree (special dendrogram plot) 
% (https://www.mathworks.com/matlabcentral/fileexchange/160048), 
% MATLAB Central File Exchange.
% =========================================================================

    properties
        ax, 
        Parent = [];
        arginList = {'Orientation', 'Parent', 'Method', 'BasePos', 'Height', 'GroupSep'};

        Data; Tree

        Orientation = 'top';     % 'top'/'left' (树状图方向)
        Method = 'average';      % Linkage method (层次聚类连接方法)
        Height = 1;              % Height of dendrogram (树状图高度)
        BasePos = 0;             % Base position for dendrogram placement (树状图放置的基准位置)
        MaxClust = 4;            % Maximum number of clusters (最大聚类数)
        Order = [];              % Leaf order (叶节点顺序)
        Group = [];              % Group assignments for leaf nodes (叶节点的分组标签)
        GroupSep = 0;            % Group separation gap (组间分离间距)
        

        XLim
        YLim
        TLim

        treeHdl
    end

    properties (Hidden)
        DataLen = 0;

    end

    methods
        function obj = SDendrogram(varargin)

            % Parse axes handle if provided (解析坐标区句柄)
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                obj.Parent = varargin{1};
                varargin(1) = [];
            else
                % No axes provided
            end

            % Store data (存储数据)
            obj.Data = varargin{1};
            varargin(1) = [];

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end
        end

        function varargout = draw(obj)
            % obj.draw() - Render the dendrogram object (渲染树状图对象)

            % Set axes handle (设置坐标轴句柄)
            if isempty(obj.Parent) && isempty(obj.ax)
                obj.ax = gca;
            else
                obj.ax = obj.Parent;
            end


            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            obj.ax.XTick = [];
            obj.ax.YTick = [];
            obj.ax.YDir = 'reverse';
            obj.ax.NextPlot = 'add';

            tFig = figure(); tAx = axes('Parent',tFig);
            if isequal(obj.Orientation, 'top')
                obj.Tree = linkage(obj.Data.', obj.Method);
            else
                obj.Tree = linkage(obj.Data  , obj.Method);
            end

            % Draw dendrogram (绘制树状图)
            [tTreeHdl, ~, obj.Order] = dendrogram(tAx, obj.Tree, 0, 'Orientation', obj.Orientation);
            obj.Group = cluster(obj.Tree, 'Maxclust',obj.MaxClust);
            obj.Group = obj.Group(obj.Order);
            obj.Group = cumsum([1, diff(obj.Group(:).') ~= 0]);

            minX = 0; maxX = 0; minY = 0; maxY = 0;
            for i = 1:length(tTreeHdl)
                minX = min(minX, min(tTreeHdl(i).XData));
                maxX = max(maxX, max(tTreeHdl(i).XData));
                minY = min(minY, min(tTreeHdl(i).YData));
                maxY = max(maxY, max(tTreeHdl(i).YData));
            end

            obj.treeHdl = gobjects(1, length(tTreeHdl));
            for i = 1:length(tTreeHdl)
                X = tTreeHdl(i).XData;
                Y = tTreeHdl(i).YData;
                switch obj.Orientation
                    case 'top'
                        Y = (Y - minY)./(maxY - minY).*(- obj.Height) + obj.BasePos;
                        for j = max(obj.Group):-1:2
                            pos = find(obj.Group == j, 1);
                            X(X >= pos) = X(X >= pos) + obj.GroupSep;
                        end
                    case 'left'
                        X = (X - minX)./(maxX - minX).*(- obj.Height) + obj.BasePos;
                        for j = max(obj.Group):-1:2
                            pos = find(obj.Group == j, 1);
                            Y(Y >= pos) = Y(Y >= pos) + obj.GroupSep;
                        end
                end
                obj.treeHdl(i) = plot(obj.Parent, X, Y, 'Color',[0,0,0], 'LineWidth',1);
            end
            delete(tFig);
            try axis(obj.ax, 'tight'); catch, end
            switch obj.Orientation
                case 'top'
                    obj.DataLen = size(obj.Data, 2) + (max(obj.Group) - 1).*obj.GroupSep;
                    tLim = [1, obj.DataLen] + [-0.5, 0.5];
                    obj.Parent.XLim(1) = min(obj.Parent.XLim(1), tLim(1));
                    obj.Parent.XLim(2) = max(obj.Parent.XLim(2), tLim(2));
                case 'left'
                    obj.DataLen = size(obj.Data, 1) + (max(obj.Group) - 1).*obj.GroupSep;
                    tLim = [1, obj.DataLen] + [-0.5, 0.5];
                    obj.Parent.YLim(1) = min(obj.Parent.YLim(1), tLim(1));
                    obj.Parent.YLim(2) = max(obj.Parent.YLim(2), tLim(2));
            end
            if nargout == 1
                varargout = {obj.Order};
            elseif nargout == 2
                varargout = {obj.Order, obj.Group};
            end
        end
    end
end