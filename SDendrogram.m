classdef SDendrogram < handle
% SDendrogram - Create and customize dendrogram
%   SD = SDendrogram(Data); Creates top-oriented dendrogram object with average linkage.
%   创建顶部方向、使用平均连接的树状图对象。
%
%   SD = SDendrogram(Data, 'Orientation', ori); specifies orientation.
%   指定方向 'top'/'left'。
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
%   'Orientation'     - 'top' (default) or 'left'
%                       树状图方向，'top' (默认) 或 'left'
%   'BasePos'         - Base position for dendrogram placement (default: 0)
%                       树状图放置的基准位置 (默认: 0)
%   'Height'          - Height of dendrogram
%                       树状图高度
%   'Method'          - Linkage method (default: 'average')
%                       层次聚类连接方法 (默认: 'average')
%   'MaxClust'        - Maximum number of clusters
%                       最大聚类数
%   'GroupSep'        - Group separation gap
%                       组间分离间距
%   'ColorList'       - Color lsit for cluster groups 
%                       分组颜色表
%   'BranchColor'     - 'on'/'off': color dendrogram branches by cluster or not
%                       是否树枝按簇着色
%   'BranchHighlight' - 'on'/'off': highlight cluster branches with translucent patches or not
%                       是否高亮树枝 (半透明背景)
%   'GroupHighlight'  - 'on'/'off': group highlight patches or not
%                       是否高亮分组
%   'HeightRatio'     - Normalized vertical positions relative to dendrogram height 
%                       树状图各部分高度的归一化位置

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

        Data                    % Input data matrix (输入数据矩阵)
        Tree                    % Linkage tree output from linkage() (聚类树结构)

        Orientation = 'top';     % 'top'/'left' (树状图方向)
        Method = 'average';      % Linkage method (层次聚类连接方法)
        Height = 1;              % Height of dendrogram (树状图高度)
        BasePos = 0;             % Base position for dendrogram placement (树状图放置的基准位置)
        MaxClust = 4;            % Maximum number of clusters (最大聚类数)
        Order = [];              % Leaf order (叶节点顺序)
        Group = [];              % Group assignments for leaf nodes (叶节点的分组标签)
        GroupSep = 0;            % Group separation gap (组间分离间距)


        % Color list for cluster groups (分组颜色表)
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
        

        % Limits for XY and Theta transformations (坐标轴及角度范围)
        XLim                % X-axis limits (X轴范围)
        YLim                % Y-axis limits (Y轴范围)
        TLim = [0,0];       % Theta limits for annular transformation (角度范围)

        % Graphics handles (图形句柄)
        treeHdl             % Line handles for dendrogram branches (树枝线条句柄)
        branchHighlightHdl  % Patch handles for branch highlights (树枝高亮面片句柄)
        groupHighlightHdl   % Patch handles for group highlights (组高亮面片句柄)
    end

    properties (Hidden)
        DataLen             % Data length after group separation adjustment (分组间距调整后的数据长度)
        X, Y                % Transformed branch vertex coordinates (变换后的分支顶点坐标)
        OX, OY              % Original branch vertex coordinates (原始分支顶点坐标)
        OXLim, OYLim        % Original axes limits (原始坐标轴范围)
        CutOff              % Cutoff height for clustering (聚类截断高度)
        CutH                % Cutoff height values per cluster (每个簇的截断高度)
        BOOL                % Boolean index for branches crossing cutoff (穿越截断线的分支索引)
        W, H                % Width and height cache (宽高缓存)
        OW, OH              % Original width and height (原始宽高)
        BW, BH              % Branch highlight boundary coordinates (树枝高亮边界坐标)
        GW, GH              % Group highlight boundary coordinates (组高亮边界坐标)
        WPos                % Adjusted leaf positions after group separation (分组间距调整后的叶位置)
        GIds                % Unique group IDs (唯一组ID)
        BIds                % Branch group IDs (树枝所属组ID)
        LIds                % Leaf group IDs (叶节点所属组ID)
        BX, BY              % Branch highlight X/Y coordinates (树枝高亮X/Y坐标)
        GX, GY              % Group highlight X/Y coordinates (组高亮X/Y坐标)
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
            if strcmpi(obj.Orientation, 'top') || strcmpi(obj.Orientation, 'bottom') 
                obj.Tree = linkage(obj.Data.', obj.Method);
            else
                obj.Tree = linkage(obj.Data  , obj.Method);
            end
            % Compute cutoff height to achieve MaxClust clusters
            % 计算截断高度，以获得 MaxClust 个簇
            obj.CutOff = median([obj.Tree(end - (obj.MaxClust - 1), 3), obj.Tree(end - (obj.MaxClust - 2), 3)]);

            % Assign cluster groups and reorder according to leaf order (分配簇组，并按叶节点顺序重新排序)
            [tTreeHdl, ~, obj.Order] = dendrogram(tAx, obj.Tree, 0, 'Orientation', obj.Orientation);
            obj.Group = cluster(obj.Tree, 'Maxclust',obj.MaxClust);
            obj.Group = obj.Group(obj.Order);
            obj.Group = cumsum([1, diff(obj.Group(:).') ~= 0]);

            % Extract original vertex coordinates (提取原始顶点坐标)
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
                case 'bottom'
                    obj.Y = (obj.Y - minY)./(maxY - minY).*(obj.Height).*(obj.HeightRatio(4) - obj.HeightRatio(3)) ...
                        + obj.BasePos + obj.Height.*(obj.HeightRatio(3) - 0);
                    for j = max(obj.Group):-1:2
                        pos = find(obj.Group == j, 1);
                        obj.X(obj.X >= pos) = obj.X(obj.X >= pos) + obj.GroupSep;
                        obj.WPos(obj.WPos >= pos) = obj.WPos(obj.WPos >= pos) + obj.GroupSep;
                    end
                    obj.OYLim = sort([obj.BasePos, obj.BasePos + obj.Height]);
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
                case 'right'
                    obj.X = (obj.X - minX)./(maxX - minX).*(obj.Height).*(obj.HeightRatio(4) - obj.HeightRatio(3)) ...
                        + obj.BasePos + obj.Height.*(obj.HeightRatio(3) - 0);
                    for j = max(obj.Group):-1:2
                        pos = find(obj.Group == j, 1);
                        obj.Y(obj.Y >= pos) = obj.Y(obj.Y >= pos) + obj.GroupSep;
                        obj.WPos(obj.WPos >= pos) = obj.WPos(obj.WPos >= pos) + obj.GroupSep;
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos + obj.Height]);
                    obj.OYLim = [min(min(obj.Y)) - .5, max(max(obj.Y)) + .5];
                    obj.W = obj.Y; obj.H = obj.X;
                    obj.OW = obj.OY; obj.OH = obj.OX;
            end
            obj.XLim = obj.OXLim; obj.YLim = obj.OYLim;
            obj.GIds = unique(obj.Group, 'stable');
            OWSet = [obj.OW(:,1:2); obj.OW(:,3:4)];
            OHSet = [obj.OH(:,1:2); obj.OH(:,3:4)];
            HSet = [obj.H(:,1:2); obj.H(:,3:4)];

            % Find branches that cross the cutoff line (寻找穿越截断线的树枝)
            obj.BOOL = (OHSet(:,1) - obj.CutOff) .* (OHSet(:,2) - obj.CutOff) < 0;
            obj.CutH = (HSet(obj.BOOL, 1) + HSet(obj.BOOL, 2)) ./ 2;
            obj.BIds = obj.Group(round(OWSet(obj.BOOL, 1)));

            % Assign leaf group IDs (分配叶节点组ID)
            tG = obj.Group(round((obj.OW(:,2) + obj.OW(:,3)) ./ 2));
            obj.LIds = all(obj.OH < obj.CutOff, 2) .* tG(:);


            for i = 1:max(obj.GIds)
                tInd = find(obj.Group == obj.GIds(i));
                tW = [obj.WPos(tInd(1)) - .5, obj.WPos(tInd(end)) + .5];
                if strcmpi(obj.Orientation, 'top') || strcmpi(obj.Orientation, 'left') 
                    tO = obj.BasePos - obj.Height.*(obj.HeightRatio(3) - 0);
                else
                    tO = obj.BasePos + obj.Height.*(obj.HeightRatio(3) - 0);
                end

                % Branch highlight patch (树枝高亮面片)
                obj.BW(i,:) = [linspace(tW(1), tW(2), 50), tW(2).*ones(1,50), ...
                               linspace(tW(2), tW(1), 50), tW(1).*ones(1,50)];
                obj.BH(i,:) = [obj.CutH(obj.BIds == obj.GIds(i)).*ones(1,50), ...
                              linspace(obj.CutH(obj.BIds == obj.GIds(i)), tO, 50), ...
                              tO.*ones(1,50), linspace(tO, obj.CutH(obj.BIds == obj.GIds(i)), 50)];

                % Group highlight patch (组高亮面片)
                if strcmpi(obj.Orientation, 'top') || strcmpi(obj.Orientation, 'left')
                    tH = obj.BasePos - obj.Height.*obj.HeightRatio([1, 2]);
                else
                    tH = obj.BasePos + obj.Height.*obj.HeightRatio([1, 2]);
                end
                obj.GH(i,:) = [tH(1).*ones(1,50), linspace(tH(1), tH(2), 50), ...
                               tH(2).*ones(1,50), linspace(tH(2), tH(1), 50)];
            end
            obj.GW = obj.BW;

            switch obj.Orientation
                case {'top', 'bottom'}
                    obj.BX = obj.BW;
                    obj.BY = obj.BH;
                    obj.GX = obj.GW;
                    obj.GY = obj.GH;
                case {'left', 'right'}
                    obj.BX = obj.BH;
                    obj.BY = obj.BW;
                    obj.GX = obj.GH;
                    obj.GY = obj.GW;
            end

            % Render dendrogram branches (绘制树枝)
            if strcmpi(obj.BranchColor, 'on')
                tCData = [zeros(1, 3); obj.ColorList];
            else
                tCData = zeros(obj.MaxClust + 1, 3);
            end

            obj.treeHdl = plot(obj.ax, obj.X.', obj.Y.', 'Color','k', 'LineWidth',1);
            set(obj.treeHdl, {'Color'}, num2cell(tCData(obj.LIds + 1, :), 2))

            % Render branch highlights (绘制树枝高亮) 
            obj.branchHighlightHdl = gobjects(1, length(obj.GIds));
            for i = 1:length(obj.GIds)
                obj.branchHighlightHdl(i) = fill(obj.ax, obj.BX(i,:), obj.BY(i,:), obj.ColorList(i,:), 'EdgeColor', 'none', 'FaceAlpha', .25);
            end

            if ~strcmpi(obj.BranchHighlight, 'on')
                for i = 1:length(obj.GIds)
                    set(obj.branchHighlightHdl(i), 'Visible','off');
                end
            end

            % Render group highlights (绘制组高亮)
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
                case {'top', 'bottom'}
                    obj.DataLen = size(obj.Data, 2) + (max(obj.Group) - 1).*obj.GroupSep;
                    tLim = [1, obj.DataLen] + [-0.5, 0.5];
                    obj.ax.XLim(1) = min(obj.ax.XLim(1), tLim(1));
                    obj.ax.XLim(2) = max(obj.ax.XLim(2), tLim(2));
                case {'left', 'right'}
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

        function varargout = setXYTLim(obj, varargin)
            % obj.setXYTLim(varargin) - Set X, Y, and Theta limits for the dendrogram (设置树状图 X轴、 Y轴、角度范围)
            %   obj.setXYTLim('XLim', [xmin, xmax], 'YLim', [ymin, ymax], 'TLim', [tmin, tmax])

            tArginList = {'XLim', 'YLim', 'TLim'};
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(tArginList), lower(varargin{i}));
                if any(tid)
                    obj.(tArginList{tid}) = varargin{i + 1};
                end
            end

            obj.XLim = sort(obj.XLim);
            obj.YLim = sort(obj.YLim);

            if abs(diff(obj.TLim)) < eps
                tXX = obj.X;
                tYY = obj.Y;
            else % Annular: interpolate each branch into 30 segments (环形：将每条枝插值为30段)
                tX = obj.X;
                tY = obj.Y;
                tT = repmat(linspace(0, 1, 30), [size(tX, 1), 1]);
                tX1 = repmat(tX(:, 1), [1, 30]); tX2 = repmat(tX(:, 2), [1, 30]);
                tX3 = repmat(tX(:, 3), [1, 30]); tX4 = repmat(tX(:, 4), [1, 30]);
                tY1 = repmat(tY(:, 1), [1, 30]); tY2 = repmat(tY(:, 2), [1, 30]);
                tY3 = repmat(tY(:, 3), [1, 30]); tY4 = repmat(tY(:, 4), [1, 30]);
                tXX = [tX1 + tT.*(tX2 - tX1), tX2 + tT.*(tX3 - tX2), tX3 + tT.*(tX4 - tX3)];
                tYY = [tY1 + tT.*(tY2 - tY1), tY2 + tT.*(tY3 - tY2), tY3 + tT.*(tY4 - tY3)];
            end
            [nX, nY] = getNewXY(tXX, tYY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            nXYC = [num2cell(nX, 2), num2cell(nY, 2)];
            set(obj.treeHdl, {'XData','YData'}, nXYC)

            [nX, nY] = getNewXY(obj.BX, obj.BY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            nXYC = [num2cell(nX, 2), num2cell(nY, 2)];
            set(obj.branchHighlightHdl, {'XData','YData'}, nXYC)

            [nX, nY] = getNewXY(obj.GX, obj.GY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            nXYC = [num2cell(nX, 2), num2cell(nY, 2)];
            set(obj.groupHighlightHdl, {'XData','YData'}, nXYC)


            try axis(obj.ax, 'tight'), catch, end
            % Helper function: coordinate transformation (辅助函数：坐标变换) 
            function [nX, nY] = getNewXY(X, Y, OXLim, OYLim, XLim, YLim, TLim)
                % GETNEWXY Transform coordinates from original space to target space with optional rotation or annular mapping.
                %   将坐标从原始空间映射到目标空间，支持旋转或环形变换。
                %   - If TLim(1) == TLim(2): apply 2D rotation (仅旋转).
                %   - If TLim(1) ~= TLim(2): map Y to angle, X to radius (环形映射)
                TLim = [-TLim(1), -TLim(2)];
                % Linear mapping to target limits (线性映射到目标范围)
                X = (X - OXLim(1))./diff(OXLim).*diff(XLim) + XLim(1);
                Y = (Y - OYLim(1))./diff(OYLim).*diff(YLim) + YLim(1);
                if abs(diff(TLim)) < eps % Rotation only (仅旋转)
                    RMat = [cos(TLim(1)), sin(TLim(1));
                           -sin(TLim(1)), cos(TLim(1))];
                    XY = [X(:), Y(:)]*RMat;
                    nX = reshape(XY(:, 1), size(X, 1), []);
                    nY = reshape(XY(:, 2), size(Y, 1), []);
                else % Annular mapping (环形映射): Y -> angle, X -> radius
                    TArr = (Y - YLim(1))./diff(YLim).*diff(TLim) + TLim(1);
                    RArr = X;
                    nX = cos(TArr).*RArr;
                    nY = sin(TArr).*RArr;
                end
            end

            if nargout == 1
                varargout = {obj};
            end
        end
    end
end