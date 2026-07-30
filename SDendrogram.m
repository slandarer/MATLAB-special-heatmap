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
        arginList = {'Orientation', 'Parent', 'Method', 'BasePos', 'Height', ...
            'GroupSep', 'HeightRatio', 'MaxClust', 'BranchColor', 'BranchHighlight', 'GroupHighlight', ...
            'XLim', 'YLim', 'TLim', 'ColorList'};

        Data; Tree

        Orientation = 'top';     % 'top'/'left' (树状图方向)
        Method = 'average';      % Linkage method (层次聚类连接方法)
        Height = 1;              % Height of dendrogram (树状图高度)
        BasePos = 0;             % Base position for dendrogram placement (树状图放置的基准位置)
        MaxClust = 4;            % Maximum number of clusters (最大聚类数)
        Order = [];              % Leaf order (叶节点顺序)
        Group = [];              % Group assignments for leaf nodes (叶节点的分组标签)
        GroupSep = 0;            % Group separation gap (组间分离间距)


        ColorList = [204,  61,  36; 243, 197,  88; 109, 174, 144;
                      48, 180, 204;   0,  79, 122]./255;

        BranchColor = 'off'
        BranchHighlight = 'off'
        GroupHighlight = 'off'

        % HeightRatio = [bottomGroup, topGroup, leafLevel, apexLevel]
        %   - bottomGroup : lower edge of GroupHighlight patch
        %   - topGroup    : upper edge of GroupHighlight patch
        %   - leafLevel   : baseline of dendrogram leaves
        %   - apexLevel   : topmost node of dendrogram
        HeightRatio = [-.1, 0, 0, 1];  
        

        XLim
        YLim
        TLim = [0,0];

        treeHdl
        branchHighlightHdl
        groupHighlightHdl
    end

    properties (Hidden)
        DataLen;
        X, Y, OX, OY, OXLim, OYLim, CutOff, CutH, BOOL
        W, H, OW, OH, BW, BH, GW, GH, WPos, GIds, BIds, LIds, 
        BX, BY, GX, GY
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

            if size(obj.ColorList, 1) < obj.MaxClust
                obj.ColorList = [obj.ColorList; rand(obj.MaxClust, 3)./5 + .3];
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

            obj.CutOff = median([obj.Tree(end - (obj.MaxClust - 1), 3), obj.Tree(end - (obj.MaxClust - 2), 3)]);

            % Draw dendrogram (绘制树状图)
            [tTreeHdl, ~, obj.Order] = dendrogram(tAx, obj.Tree, 0, 'Orientation', obj.Orientation);
            obj.Group = cluster(obj.Tree, 'Maxclust',obj.MaxClust);
            obj.Group = obj.Group(obj.Order);
            obj.Group = cumsum([1, diff(obj.Group(:).') ~= 0]);

            obj.OX = reshape([tTreeHdl(:).XData], 4, []).';
            obj.OY = reshape([tTreeHdl(:).YData], 4, []).';
            minX = min(min(obj.OX)); maxX = max(max(obj.OX));
            minY = min(min(obj.OY)); maxY = max(max(obj.OY));

            obj.treeHdl = gobjects(1, length(tTreeHdl)); delete(tFig);
            obj.X = obj.OX; obj.Y = obj.OY;
            obj.WPos = 1:length(obj.Group);
            switch obj.Orientation
                case 'top'
                    obj.Y = (obj.Y - minY)./(maxY - minY).*(- obj.Height).*(obj.HeightRatio(4) - obj.HeightRatio(3)) ...
                        + obj.BasePos - obj.Height.*(obj.HeightRatio(3) - 0);
                    for j = max(obj.Group):-1:2
                        pos = find(obj.Group == j, 1);
                        obj.X(obj.X >= pos) = obj.X(obj.X >= pos) + obj.GroupSep;
                        obj.WPos(obj.WPos >= pos) = obj.WPos(obj.WPos >= pos) + obj.GroupSep;
                    end
                    obj.OYLim = sort([obj.BasePos, obj.BasePos - obj.Height]);
                    obj.OXLim = [min(min(obj.X)) - .5, max(max(obj.X)) + .5];
                    obj.W = obj.X; obj.H = obj.Y;
                    obj.OW = obj.OX; obj.OH = obj.OY;
                case 'left'
                    obj.X = (obj.X - minX)./(maxX - minX).*(- obj.Height).*(obj.HeightRatio(4) - obj.HeightRatio(3)) ...
                        + obj.BasePos - obj.Height.*(obj.HeightRatio(3) - 0);
                    for j = max(obj.Group):-1:2
                        pos = find(obj.Group == j, 1);
                        obj.Y(obj.Y >= pos) = obj.Y(obj.Y >= pos) + obj.GroupSep;
                        obj.WPos(obj.WPos >= pos) = obj.WPos(obj.WPos >= pos) + obj.GroupSep;
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos - obj.Height]);
                    obj.OYLim = [min(min(obj.Y)) - .5, max(max(obj.Y)) + .5];
                    obj.W = obj.Y; obj.H = obj.X;
                    obj.OW = obj.OY; obj.OH = obj.OX;
            end
            obj.GIds = unique(obj.Group, 'stable');
            OWSet = [obj.OW(:,1:2); obj.OW(:,3:4)];
            OHSet = [obj.OH(:,1:2); obj.OH(:,3:4)];
            HSet = [obj.H(:,1:2); obj.H(:,3:4)];
            obj.BOOL = (OHSet(:,1) - obj.CutOff).*(OHSet(:,2) - obj.CutOff) < 0;
            obj.CutH = (HSet(obj.BOOL, 1) + HSet(obj.BOOL, 2))./2;
            obj.BIds = obj.Group(round(OWSet(obj.BOOL, 1)));
            tG = obj.Group(round((obj.OW(:,2) + obj.OW(:,3))./2));
            obj.LIds = all(obj.OH < obj.CutOff, 2).*tG(:);


            for i = 1:max(obj.GIds)
                tInd = find(obj.Group == obj.GIds(i));
                tW = [obj.WPos(tInd(1)) - .5, obj.WPos(tInd(end)) + .5];
                tO = obj.BasePos - obj.Height.*(obj.HeightRatio(3) - 0);
                obj.BW(i,:) = [linspace(tW(1), tW(2), 50), tW(2).*ones(1,50), ...
                               linspace(tW(2), tW(1), 50), tW(1).*ones(1,50)];
                obj.BH(i,:) = [obj.CutH(obj.BIds == obj.GIds(i)).*ones(1,50), ...
                              linspace(obj.CutH(obj.BIds == obj.GIds(i)), tO, 50), ...
                              tO.*ones(1,50), linspace(tO, obj.CutH(obj.BIds == obj.GIds(i)), 50)];
                tH = obj.BasePos - obj.Height.*obj.HeightRatio([1, 2]);
                obj.GH(i,:) = [tH(1).*ones(1,50), linspace(tH(1), tH(2), 50), ...
                               tH(2).*ones(1,50), linspace(tH(2), tH(1), 50)];
            end
            obj.GW = obj.BW;

            switch obj.Orientation
                case 'top'
                    obj.BX = obj.BW;
                    obj.BY = obj.BH;
                    obj.GX = obj.GW;
                    obj.GY = obj.GH;
                case 'left'
                    obj.BX = obj.BH;
                    obj.BY = obj.BW;
                    obj.GX = obj.GH;
                    obj.GY = obj.GW;
            end
            if strcmpi(obj.BranchColor, 'on')
                tCData = [zeros(1, 3); obj.ColorList];
            else
                tCData = zeros(obj.MaxClust + 1, 3);
            end
            
            obj.treeHdl = gobjects(1, length(obj.LIds));
            for i = 1:length(obj.LIds)
                obj.treeHdl(i) = plot(obj.ax, obj.X(i,:), obj.Y(i,:), 'Color',tCData(obj.LIds(i) + 1, :), 'LineWidth',1);
            end

            obj.branchHighlightHdl = gobjects(1, length(obj.GIds));
            for i = 1:length(obj.GIds)
                obj.branchHighlightHdl(i) = fill(obj.ax, obj.BX(i,:), obj.BY(i,:), obj.ColorList(i,:), 'EdgeColor', 'none', 'FaceAlpha', .25);
            end

            if ~strcmpi(obj.BranchHighlight, 'on')
                for i = 1:length(obj.GIds)
                    set(obj.branchHighlightHdl(i), 'Visible','off');
                end
            end

            obj.groupHighlightHdl = gobjects(1, length(obj.GIds));
            for i = 1:length(obj.GIds)
                obj.groupHighlightHdl(i) = fill(obj.ax, obj.GX(i,:), obj.GY(i,:), obj.ColorList(i,:), 'EdgeColor', 'none', 'FaceAlpha', .9);
            end

            if ~strcmpi(obj.GroupHighlight, 'on')
                for i = 1:length(obj.GIds)
                    set(obj.groupHighlightHdl(i), 'Visible','off');
                end
            end

            try axis(obj.ax, 'tight'); catch, end
            switch obj.Orientation
                case 'top'
                    obj.DataLen = size(obj.Data, 2) + (max(obj.Group) - 1).*obj.GroupSep;
                    tLim = [1, obj.DataLen] + [-0.5, 0.5];
                    obj.ax.XLim(1) = min(obj.ax.XLim(1), tLim(1));
                    obj.ax.XLim(2) = max(obj.ax.XLim(2), tLim(2));
                case 'left'
                    obj.DataLen = size(obj.Data, 1) + (max(obj.Group) - 1).*obj.GroupSep;
                    tLim = [1, obj.DataLen] + [-0.5, 0.5];
                    obj.ax.YLim(1) = min(obj.ax.YLim(1), tLim(1));
                    obj.ax.YLim(2) = max(obj.ax.YLim(2), tLim(2));
            end
            if nargout == 1
                varargout = {obj.Order};
            elseif nargout == 2
                varargout = {obj.Order, obj.Group};
            end
        end

        function varargout = set(obj, varargin)
            % Properties setting
            
            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            if nargout == 1
                varargout = {obj};
            end
        end
    end
end