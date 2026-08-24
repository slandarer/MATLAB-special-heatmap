classdef SVarRowChart < handle
% SVarRowChart - Create a row-based variable visualization chart (创建逐行变量可视化图表)
%   This class constructs a chart where each row represents a variable,
%   displayed as a horizontal heatmap bar on the left with a legend or
%   colorbar on the right. It supports both numerical and categorical data.
%   该类构建一个每行代表一个变量的图表，左侧显示为横向热图条，
%   右侧显示图例或颜色条，支持数值型和分类型数据。

% Syntax (语法):
%   SVR = SVarRowChart();                       % Create in current axes (在当前坐标区创建)
%
%   SVR = SVarRowChart(ax);                     % Create in specified axes (在指定坐标区创建)
%
%   SVR = SVarRowChart(___, propName, propVal); % Set properties at construction (创建时设置属性)
%
% Methods (方法):
%   hdl = SVR.addRow(Data, propName, propVal);  % Add a variable row (添加一个变量行)
%
% Properties (属性):
%   LeftWidth  - Width of the left panel (热图条宽度)
%   RightWidth - Width of the right panel (图例/颜色条宽度)
%   ColSep     - Gap between left and right panels (左右面板间距)
%   RowHeight  - Height of each row (每行高度)
%   RowSep     - Gap between rows (行间距)
%   TitleFontProp   - Cell array of title text properties (字体属性)
%
% Example (示例):
%   SVR = SVarRowChart();
%   SVR.addRow(randn(1, 50), 'Title','Variable-A', 'Unit','cm');
%   SVR.addRow({'Cat','Dog','Cat','Bird','Dog','Bird'}, 'Title','Variable-B');

% =========================================================================
% Zhaoxu Liu / slandarer (2023). special heatmap
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap),
% MATLAB Central File Exchange. Retrieved March 1, 2023.
% =========================================================================
% Inspired by : https://www.mathworks.com/matlabcentral/fileexchange/71922-hcp-heatmapcovariateplot
%               https://bitbucket.org/manuela_s/hcp/src/master/


    properties
        ax
        Parent = []
        arginList = {'Parent', 'LeftWidth', 'RightWidth', 'ColSep', 'RowHeight', 'RowSeP', 'FontProp'}

        LeftWidth = 20   % Width of the left panel (热图条面板宽度)
        RightWidth = 20  % Width of the right panel (图例/颜色条面板宽度)
        IconWidth = []   % Width of each legend icon (图例图标宽度, 自动计算)
        RowHeight = 1    % Height of each row (每行高度)
        ColSep =  5      % Gap between left and right panels (左右面板间距)
        RowSep = .5      % Vertical gap between rows (行间距)

        %     LeftWidth      ColSep     RightWidth
        %  ←--------------→  ←----→  ←--------------→
        % ┌────────────────┐        ┌────────────────┐ ↑ 
        % |                |        |                | | RowHeight
        % └────────────────┘        └────────────────┘ ↓
        %                                              ↑ 
        %                                              | RowSeP
        %                                              ↓
        % ┌────────────────┐        ┌────────────────┐
        % └────────────────┘        └────────────────┘
        % ┌────────────────┐        ┌────────────────┐
        % └────────────────┘        └────────────────┘
        % ┌────────────────┐        ┌────────────────┐
        % └────────────────┘        └────────────────┘

        Order = [];
        RowHdlList = {};
        Sorted = []
        TitleFontProp = {'FontSize',15, 'FontName','Times New Roman'};
        VarFontProp = {'FontSize',12, 'FontName','Times New Roman'};
        
    end

    properties (Hidden)
        tBase = 0;
        tColorList = [204,  61,  36; 243, 197,  88; 109, 174, 144;
                      48, 180, 204;   0,  79, 122]./255;
        tColormap =  [.97, .99, .94; .95, .98, .92; .92, .97, .90;
             .90, .96, .88; .88, .95, .86; .86, .94, .83; 
             .84, .94, .81; .82, .93, .79; .79, .92, .77; 
             .75, .90, .75; .72, .89, .74; .68, .88, .72; 
             .64, .86, .72; .60, .84, .73; .55, .83, .75;
             .51, .81, .76; .46, .79, .78; .41, .76, .79; 
             .37, .74, .81; .32, .71, .82; .28, .68, .81; 
             .25, .64, .79; .21, .60, .77; .18, .56, .75; 
             .14, .52, .73; .11, .49, .71; .07, .45, .69; 
             .04, .41, .68; .03, .37, .64; .03, .33, .59;
             .03, .29, .55; .03, .25, .51];
    end

    methods
        function obj = SVarRowChart(varargin)
            if ~isempty(varargin) && isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                obj.Parent = varargin{1};
                varargin(1) = [];
            else
                % No axes provided
            end

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            if isempty(obj.Parent) && isempty(obj.ax)
                obj.ax = gca;
            else
                obj.ax = obj.Parent;
            end
            obj.ax.NextPlot = 'add';
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            obj.ax.YDir = 'reverse';
            obj.ax.DataAspectRatio = [1, 1, 1];
        end

        function varargout = addHeatmap(obj, Data, varargin)
            % addHeatmap - Add a to the chart
            %   hdl = obj.addHeatmap(Data) adds a heatmap using the numeric matrix Data.
            %   
            %   hdl = obj.addHeatmap(___, propName, propVal)
            %
            % Parameters (参数):
            %   'ColorList'  - Custom color list for categorical data (分类热图自定义颜色)
            %   'Colormap'   - Colormap for numerical heatmap (数值热图颜色映射)
            %   'CLim'       - Color limits for numerical data [min, max] (数值颜色范围)
            %   'RowName'    - Row names for heatmap rows (行名称)
            %   'ColName'    - Column names for heatmap columns (列名称)
            %   'Title'      - Title displayed above the heatmap (热图标题)
            %   'TopTree'    - Dendrogram to display on the top side (上侧树状图)
            %   'RightTree'  - Dendrogram to display on the right side (右侧树状图)
            %   'TopBlock'   - Block annotation to display on the top side (上侧分组色块)
            %   'RightBlock' - Block annotation to display on the right side (右侧分组色块)
            %   'RowClust'   - Maximum number of clusters for row clustering (行最大聚类数)
            %   'ColClust'   - Maximum number of clusters for col clustering (列最大聚类数)
            %   'RowGap'     - Gap between heatmap rows (热图行间距)
            %   'Method'     - Clustering method (聚类方法)
            %   'CBreak'     - Break positions for colorbar (颜色条断点位置)

            hdl = struct;
            tArginList = {'ColorList', 'Colormap', 'CLim', ...
                'RowName','ColName', 'Title', 'TopTree', ...
                'RightTree', 'TopBlock', 'RightBlock', 'RowClust', ...
                'ColClust', 'RowGap', 'Method','CBreak'};
            % Data = Data.';
            hdl.Title = '';
            [R, C] = size(Data);
            hdl.RowName = compose('Row-%d', 1:R);
            hdl.ColName = compose('Col-%d', 1:C);
            hdl.ColorList = obj.tColorList;
            hdl.Colormap = obj.tColormap;
            hdl.CLim = [min(min(Data)), max(max(Data))];
            hdl.CBreak = [];
            hdl.Method = 'average';
            hdl.RowClust = 3;
            hdl.ColClust = 3;
            hdl.TopBlock = 'on';
            hdl.TopTree = 'on';
            hdl.RightBlock = 'on';
            hdl.RightTree = 'on';
            hdl.RowGap = 'on';
            hdl.RowGroup = ones(1, size(Data, 1));
            hdl.ColGroup = ones(1, size(Data, 2));
            hdl.RowOrder = 1:size(Data, 1);
            hdl.ColOrder = 1:size(Data, 2);
            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(tArginList), lower(varargin{i}));
                if any(tid)
                    hdl.(tArginList{tid}) = varargin{i + 1};
                end
            end
            if size(hdl.ColorList, 1) < max(hdl.RowClust, hdl.ColClust)
                hdl.ColorList = [hdl.ColorList; 
                                 rand(max(hdl.RowClust, hdl.ColClust), 3).*.5 + .5];
            end

            if strcmpi(hdl.TopTree, 'on') || strcmpi(hdl.TopBlock, 'on')
                tFig = figure(); tAx = axes('Parent',tFig);
                hdl.ColTree = linkage(Data.', hdl.Method);
                [tColTreeHdl, ~, hdl.ColOrder] = dendrogram(tAx, hdl.ColTree, 0, 'Orientation', 'top');
                hdl.ColGroup = cluster(hdl.ColTree, 'Maxclust',hdl.ColClust);
                hdl.ColGroup = hdl.ColGroup(hdl.ColOrder);
                [~, ~, hdl.ColGroup] = unique(hdl.ColGroup, 'stable');
                hdl.ColGroup = hdl.ColGroup(:).';

                obj.Order = hdl.ColOrder;
                for i = 1:length(obj.RowHdlList)
                    if ~obj.Sorted(i)
                        patchHdl = obj.RowHdlList{i}.Heatmap.patchHdl;
                        patchHdl.CData(1:end-1,:,:) = patchHdl.CData(obj.Order,:,:);
                        obj.Sorted(i) = true;
                    end
                end
                if strcmpi(hdl.TopTree, 'on')
                    % Extract original vertex coordinates (提取原始顶点坐标)
                    OX = reshape([tColTreeHdl(:).XData], 4, []);
                    OY = reshape([tColTreeHdl(:).YData], 4, []);
                    minX = min(min(OX)) - .5; minY = min(min(OY));
                    maxX = max(max(OX)) + .5; maxY = max(max(OY));
                    Y =  - (OY - minY)./(maxY - minY).*5*obj.RowHeight + obj.tBase + 5*obj.RowHeight;
                    X = (OX - minX)./(maxX - minX).*obj.LeftWidth;
                    Y = [Y; nan(1, size(OY, 2))];
                    X = [X; nan(1, size(OX, 2))];
                    hdl.Heatmap.topTreeHdl = plot(obj.ax, X(:), Y(:), 'Color','k', 'LineWidth',1);
                    obj.tBase = obj.tBase + 5*obj.RowHeight + obj.RowSep;
                end
                delete(tFig); Data = Data(:, obj.Order);
                if strcmpi(hdl.TopBlock, 'on')
                    [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, length(Data) + 1));
                    CMesh = zeros([size(XMesh), 3]);
                    CList = hdl.ColorList(hdl.ColGroup, :); 
                    CMesh(1:end-1, :, 1) = CList(:, [1, 1]);
                    CMesh(1:end-1, :, 2) = CList(:, [2, 2]);
                    CMesh(1:end-1, :, 3) = CList(:, [3, 3]);
                    hdl.Heatmap.topBlockHdl = surf(obj.ax, XMesh.*obj.LeftWidth, ...
                        obj.tBase + YMesh.*obj.RowHeight, ...
                        XMesh.*0, 'CData',CMesh, 'EdgeColor','k', 'FaceColor','flat', 'LineWidth',1);
                    obj.tBase = obj.tBase + obj.RowHeight + obj.RowSep;
                end
            end

            hBase = obj.tBase;

            

            if strcmpi(hdl.RightTree, 'on') || strcmpi(hdl.RightBlock, 'on')
                tFig = figure(); tAx = axes('Parent',tFig);
                hdl.RowTree = linkage(Data, hdl.Method);
                [tRowTreeHdl, ~, hdl.RowOrder] = dendrogram(tAx, hdl.RowTree, 0, 'Orientation', 'right');
                hdl.RowGroup = cluster(hdl.RowTree, 'Maxclust',hdl.RowClust);
                hdl.RowGroup = hdl.RowGroup(hdl.RowOrder);
                [~, ~, hdl.RowGroup] = unique(hdl.RowGroup, 'stable');
                hdl.RowGroup = hdl.RowGroup(:).';

                if strcmpi(hdl.RightTree, 'on')
                    OX = reshape([tRowTreeHdl(:).XData], 4, []);
                    OY = reshape([tRowTreeHdl(:).YData], 4, []);

                    if strcmpi(hdl.RowGap, 'on')
                        for j = max(hdl.RowGroup):-1:2
                            pos = find(hdl.RowGroup == j, 1);
                            OY(OY >= pos) = OY(OY >= pos) + 1/obj.RowHeight*obj.RowSep;
                        end
                    end
                    minX = min(min(OX)); minY = min(min(OY)) - .5;
                    maxX = max(max(OX)); % maxY = max(max(OY)) + .5;
                    Y = (OY - minY).*obj.RowHeight + obj.tBase;
                    if strcmpi(hdl.RightBlock, 'on')
                        X = (OX - minX)./(maxX - minX).*5*obj.RowHeight + obj.LeftWidth + obj.RowHeight + 2*obj.RowSep;
                    else
                        X = (OX - minX)./(maxX - minX).*5*obj.RowHeight + obj.LeftWidth + obj.RowSep;
                    end
                    Y = [Y; nan(1, size(OY, 2))];
                    X = [X; nan(1, size(OX, 2))];
                    hdl.Heatmap.rightTreeHdl = plot(obj.ax, X(:), Y(:), 'Color','k', 'LineWidth',1);
                end
                delete(tFig); Data = Data(hdl.RowOrder, :);
                if strcmpi(hdl.RightBlock, 'on')
                    tYCP = 1:size(Data, 1);
                    if strcmpi(hdl.RowGap, 'on')
                        for j = max(hdl.RowGroup):-1:2
                            pos = find(hdl.RowGroup == j, 1);
                            tYCP(tYCP >= pos) = tYCP(tYCP >= pos) + 1/obj.RowHeight*obj.RowSep;
                        end
                    end
                    tYCP = (tYCP - .5).*obj.RowHeight + obj.tBase;
                    for j = 1:max(hdl.RowGroup)
                        pos1 = find(hdl.RowGroup == j, 1);
                        pos2 = find(hdl.RowGroup == j, 1, 'last');
                        Y = [tYCP(pos1) - obj.RowHeight/2,  tYCP(pos1) - obj.RowHeight/2, tYCP(pos2) + obj.RowHeight/2, tYCP(pos2) + obj.RowHeight/2];
                        X = obj.LeftWidth + obj.RowSep + [0, obj.RowHeight, obj.RowHeight, 0];
                        hdl.Heatmap.rightBlockHdl(i) = fill(obj.ax, X, Y, hdl.ColorList(j,:), 'EdgeColor','k', 'LineWidth',1);
                    end
                end
            end
            tYCP = 1:size(Data, 1);
            if strcmpi(hdl.RowGap, 'on')
                for j = max(hdl.RowGroup):-1:2
                    pos = find(hdl.RowGroup == j, 1);
                    tYCP(tYCP >= pos) = tYCP(tYCP >= pos) + 1/obj.RowHeight*obj.RowSep;
                end
            end
            for i = 1:size(Data, 1)
                hdl.Heatmap.rowTextHdl(i) = text(obj.ax, 0, obj.tBase + (tYCP(i) - .5).*obj.RowHeight, ...
                    [hdl.RowName{hdl.RowOrder(i)},' '], obj.VarFontProp{:}, 'HorizontalAlignment','right');
            end
            values = linspace(hdl.CLim(1), hdl.CLim(2), size(hdl.Colormap, 1) + 1);
            for i = 1:max(hdl.RowGroup)
                tData = Data(hdl.RowGroup == i, :);
                [YMesh, XMesh] = meshgrid(linspace(0, 1, size(tData, 1) + 1), linspace(0, 1, size(tData, 2) + 1));
                CMesh = zeros([size(XMesh), 3]);
                for j = 1:size(tData, 1)
                    counts = sum(repmat(tData(j, :).', [1, length(values)]) >= repmat(values, [length(tData(j, :)), 1]), 2);
                    counts(counts <= 0) = 1;
                    counts(counts > size(hdl.Colormap, 1)) = size(hdl.Colormap, 1);
                    CList = hdl.Colormap(counts, :); 
                    CMesh(1:end-1, j, 1) = CList(:, 1);
                    CMesh(1:end-1, j, 2) = CList(:, 2);
                    CMesh(1:end-1, j, 3) = CList(:, 3);
                    
                end
                hdl.Heatmap.patchHdl(i) = surf(obj.ax, XMesh.*obj.LeftWidth, ...
                    obj.tBase + YMesh.*obj.RowHeight.*size(tData, 1), ...
                    XMesh.*0, 'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat', 'LineWidth',1);
                hdl.Heatmap.boxHdl(i) = mesh(obj.ax, XMesh(:, [1,end]).*obj.LeftWidth, ...
                    obj.tBase + YMesh(:, [1,end]).*obj.RowHeight.*size(tData, 1), ...
                    XMesh(:, [1,end]).*0 + .01, 'EdgeColor','w', 'LineWidth',1, 'FaceColor','none');
                hdl.Heatmap.frameHdl(i) = mesh(obj.ax, XMesh([1,end], [1,end]).*obj.LeftWidth, ...
                    obj.tBase + YMesh([1,end], [1,end]).*obj.RowHeight.*size(tData, 1), ...
                    XMesh([1,end], [1,end]).*0 + .02, 'EdgeColor','k', 'LineWidth',1, 'FaceColor','none');
                if strcmpi(hdl.RowGap, 'on')
                    obj.tBase = obj.tBase + obj.RowHeight.*size(tData, 1) + obj.RowSep;
                else
                    obj.tBase = obj.tBase + obj.RowHeight.*size(tData, 1);
                end
            end
            if strcmpi(hdl.RowGap, 'on')
            else
                obj.tBase = obj.tBase + obj.RowSep;
            end
            for i = 1:size(Data, 2)
                hdl.Heatmap.colTextHdl(i) = text(obj.ax, (i - .5)./size(Data, 2).*obj.LeftWidth, obj.tBase - obj.RowSep, ...
                    [hdl.ColName{hdl.ColOrder(i)},' '], obj.VarFontProp{:}, 'HorizontalAlignment','right', 'Rotation',90);
            end

            lBase = obj.LeftWidth + obj.ColSep;
            if strcmpi(hdl.RightBlock, 'on')
                lBase = lBase + obj.RowSep + obj.RowHeight;
            end
            if strcmpi(hdl.RightTree, 'on')
                lBase = lBase + obj.RowSep + obj.RowHeight*5;
            end
            if isempty(hdl.CBreak)
                cbar = colorbar(obj.ax);
                cbar.Position(4) = cbar.Position(4).*.6;
                clim(obj.ax, hdl.CLim);
                hdl.CBreak = cbar.YTick;
                delete(cbar);
            end
            tCbreak = hdl.CBreak;
            tCbreak(tCbreak < hdl.CLim(1)) = [];
            tCbreak(tCbreak > hdl.CLim(2)) = [];
            hHeight = size(Data, 1).*obj.RowHeight;
            if (strcmpi(hdl.RightTree, 'on') || strcmpi(hdl.RightBlock, 'on')) && strcmpi(hdl.RowGap, 'on')
                hHeight = hHeight + obj.RowSep.*(max(hdl.RowGroup) - 1);
            end

            [XMesh, YMesh] = meshgrid([0, 1], linspace(0, 1, size(hdl.Colormap, 1) + 1));
            CMesh = zeros([size(XMesh), 3]);
            CMesh(1:end-1, :, 1) = hdl.Colormap(end:-1:1, [1, 1]);
            CMesh(1:end-1, :, 2) = hdl.Colormap(end:-1:1, [2, 2]);
            CMesh(1:end-1, :, 3) = hdl.Colormap(end:-1:1, [3, 3]);

            hdl.Colorbar.patchHdl = surf(obj.ax, lBase + 1.*XMesh.*obj.RowHeight, hBase + YMesh.*hHeight, YMesh.*0, ...
                'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat');

            tY = 1 - [0, (tCbreak - hdl.CLim(1))./(hdl.CLim(2) - hdl.CLim(1)), 1];
            [XMesh, YMesh] = meshgrid([0, 1], tY);
            hdl.Colorbar.boxHdl = mesh(obj.ax, lBase + 1.*XMesh.*obj.RowHeight, hBase + YMesh.*hHeight, YMesh.*0, ...
                'EdgeColor','k', 'FaceColor','none', 'LineWidth',1);
            for i = 1:length(tCbreak)
                hdl.Colorbar.textHdl(i) = text(obj.ax, lBase + 1.*obj.RowHeight, ...
                    hBase + (1 - (tCbreak(i) - hdl.CLim(1))./(hdl.CLim(2) - hdl.CLim(1))).*hHeight, [' ', num2str(tCbreak(i))], ...
                    obj.TitleFontProp{:});
            end
            hdl.titleHdl = text(obj.ax, lBase + 1.*obj.RowHeight + obj.ColSep, hBase + hHeight/2, hdl.Title, 'Rotation',90, 'HorizontalAlignment','center', ...
                'VerticalAlignment','top', obj.TitleFontProp{:});

            obj.tBase = obj.tBase + 5*obj.RowHeight;


            obj.tColorList = hdl.ColorList;
            obj.tColormap = hdl.Colormap;
            axis(obj.ax, 'tight');
            if nargout == 1
                varargout = {hdl};
            end
        end

        function varargout = addRow(obj, Data, varargin)
            % addRow - Add a new variable row to the chart
            %   hdl = obj.addRow(Data) adds a row with numerical or cell Data.
            %   
            %   hdl = obj.addRow(___, propName, propVal)
            %
            % Parameters (参数):
            %   'Title'      - Row title displayed on the left (行标题)
            %   'Unit'       - Unit string for colorbar label (单位)
            %   'Label'      - Category labels for categorical data (分类标签)
            %   'ColorList'  - Custom color list for data (自定义颜色)
            %   'CLim'       - Color limits for numerical data [min, max] (数值颜色范围)
            %   'IconColNum' - Number of legend columns for categorical data (图例列数)


            hdl = struct;
            
            if ~isempty(obj.Order)
                Data = Data(obj.Order);
                obj.Sorted = [obj.Sorted, true];
            else
                obj.Sorted = [obj.Sorted, false];
            end
            
            tArginList = {'ColorList', 'CLim', 'Unit', 'Title', 'Label', 'IconColNum'};

            hdl.Title = '';
            hdl.Label = {};
            hdl.Unit = '';
            if iscell(Data)
                hdl.ColorList = obj.tColorList;
            else
                hdl.ColorList = obj.tColormap;
            end
            hdl.CLim = [];
            hdl.IconColNum = [];

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(tArginList), lower(varargin{i}));
                if any(tid)
                    hdl.(tArginList{tid}) = varargin{i + 1};
                end
            end

            if iscell(Data)
                flag = true;
            else
                flag = false;
            end

            if flag
                if isempty(hdl.Label)
                    [vTxt, ~, Data] = unique(Data, 'stable');
                else
                    [~, Data] = ismember(Data, hdl.Label);
                    vTxt = hdl.Label;
                end
                hdl.ColorList = [hdl.ColorList; rand(length(vTxt), 3).*.5 + .5];
                hdl.ColorList = hdl.ColorList(1:length(vTxt), :);
                hdl.CLim = [1, length(vTxt)];
            else
                if isempty(hdl.CLim)
                    hdl.CLim = [min(Data), max(Data)];
                end
                vTxt = {num2str(hdl.CLim(1)), num2str(hdl.CLim(2))};
                if ~isempty(hdl.Unit)
                    vTxt{2} = [vTxt{2}, ' [', hdl.Unit, ']'];
                end
            end

            Data = Data(:);

            % Draw variable row (绘制变量条热图)
            values = linspace(hdl.CLim(1), hdl.CLim(2), size(hdl.ColorList, 1) + 1);
            counts = sum(repmat(Data, [1, length(values)]) >= repmat(values, [length(Data), 1]), 2);
            counts(counts <= 0) = 1;
            counts(counts > size(hdl.ColorList, 1)) = size(hdl.ColorList, 1);
            CList = hdl.ColorList(counts, :); 

            [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, length(Data) + 1));
            CMesh = zeros([size(XMesh), 3]);
            CMesh(1:end-1, :, 1) = CList(:, [1, 1]);
            CMesh(1:end-1, :, 2) = CList(:, [2, 2]);
            CMesh(1:end-1, :, 3) = CList(:, [3, 3]);

            hdl.titleHdl = text(obj.ax, 0, obj.tBase + obj.RowHeight/2, ...
                [hdl.Title,' '], 'HorizontalAlignment','right', obj.TitleFontProp{:});
            hdl.Heatmap.patchHdl = surf(obj.ax, XMesh.*obj.LeftWidth, ...
                obj.tBase + YMesh.*obj.RowHeight, ...
                XMesh.*0, 'CData',CMesh, 'EdgeColor','k', 'FaceColor','flat', 'LineWidth',1);

            % Draw Colorbar or Legend (绘制颜色条或者图例)
            if flag
                if isempty(hdl.IconColNum) || hdl.IconColNum < length(vTxt)
                    hdl.IconColNum = length(vTxt);
                end
                if isempty(obj.IconWidth)
                    obj.IconWidth = obj.RowHeight;
                    tWidth = obj.RightWidth./(hdl.IconColNum + 3 * (hdl.IconColNum - 1));
                    tWidth(isinf(tWidth)) = obj.IconWidth;
                    obj.IconWidth = min(obj.IconWidth, tWidth);
                end

                SepWith = (obj.RightWidth - (obj.IconWidth * hdl.IconColNum))/(hdl.IconColNum - 1);
                SepWith(isinf(SepWith)) = 0;

                hdl.Legend.patchHdl = gobjects(1, hdl.IconColNum);
                % hdl.Legend.textHdl = gobjects(1, length(vTxt));
                for i = 1:length(vTxt)
                    hdl.Legend.patchHdl(i) = fill(obj.ax, ...
                        [0,1,1,0].*obj.IconWidth + (obj.IconWidth + SepWith)*(i - 1) + (obj.LeftWidth + obj.ColSep),...
                        [0,0,1,1].*obj.RowHeight + obj.tBase, ...
                        hdl.ColorList(i, :), 'EdgeColor','k', 'LineWidth',1);
                    hdl.Legend.textHdl(i) = text(obj.ax, obj.LeftWidth + obj.ColSep + obj.IconWidth + (i - 1)*(obj.IconWidth + SepWith), ...
                        obj.tBase + obj.RowHeight/2, ...
                        [' ', vTxt{i}], 'HorizontalAlignment','left', obj.TitleFontProp{:});

                end
            else
                [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, size(hdl.ColorList, 1) + 1));
                CMesh = zeros([size(XMesh), 3]);
                CMesh(1:end-1, :, 1) = hdl.ColorList(:, [1, 1]);
                CMesh(1:end-1, :, 2) = hdl.ColorList(:, [2, 2]);
                CMesh(1:end-1, :, 3) = hdl.ColorList(:, [3, 3]);
                hdl.Colorbar.patchHdl = surf(obj.ax, XMesh.*obj.RightWidth + (obj.LeftWidth + obj.ColSep), ...
                    obj.tBase + YMesh.*obj.RowHeight, ...
                    XMesh.*0, 'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat');
                hdl.Colorbar.frameHdl = plot(obj.ax, [0,1,1,0,0].*obj.RightWidth + (obj.LeftWidth + obj.ColSep), ...
                    obj.tBase + [0,0,1,1,0].*obj.RowHeight, ...
                    'Color','k', 'LineWidth',1);
                hdl.Colorbar.textHdl(1) = text(obj.ax, obj.LeftWidth + obj.ColSep, ...
                    obj.tBase + obj.RowHeight/2, ...
                    [vTxt{1},' '], 'HorizontalAlignment','right', obj.TitleFontProp{:});
                hdl.Colorbar.textHdl(2) = text(obj.ax, obj.LeftWidth + obj.ColSep + obj.RightWidth, ...
                    obj.tBase + obj.RowHeight/2, ...
                    [' ', vTxt{2}], 'HorizontalAlignment','left', obj.TitleFontProp{:});
            end

            if flag
                obj.tColorList = hdl.ColorList;
            else
                obj.tColormap = hdl.ColorList;
            end
            obj.tBase = obj.tBase + obj.RowHeight + obj.RowSep;

            obj.RowHdlList = [obj.RowHdlList, hdl];
            axis(obj.ax, 'tight');
            if nargout == 1
                varargout = {hdl};
            end
        end
    end
end