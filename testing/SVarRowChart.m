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
%   FontProp   - Cell array of text properties (字体属性)
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

        FontProp = {'FontSize',15, 'FontName','Times New Roman'};
        
    end

    properties (Hidden)
        tIndex = 1;
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

            hdl.titleHdl = text(obj.ax, 0, (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + obj.RowHeight/2, ...
                [hdl.Title,' '], 'HorizontalAlignment','right', obj.FontProp{:});
            hdl.Heatmap.patchHdl = surf(obj.ax, XMesh.*obj.LeftWidth, ...
                (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + YMesh.*obj.RowHeight, ...
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
                        [0,0,1,1].*obj.RowHeight + (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep), ...
                        hdl.ColorList(i, :), 'EdgeColor','k', 'LineWidth',1);
                    hdl.Legend.textHdl(i) = text(obj.ax, obj.LeftWidth + obj.ColSep + obj.IconWidth + (i - 1)*(obj.IconWidth + SepWith), ...
                        (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + obj.RowHeight/2, ...
                        [' ', vTxt{i}], 'HorizontalAlignment','left', obj.FontProp{:});

                end
            else
                [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, size(hdl.ColorList, 1) + 1));
                CMesh = zeros([size(XMesh), 3]);
                CMesh(1:end-1, :, 1) = hdl.ColorList(:, [1, 1]);
                CMesh(1:end-1, :, 2) = hdl.ColorList(:, [2, 2]);
                CMesh(1:end-1, :, 3) = hdl.ColorList(:, [3, 3]);
                hdl.ColorBar.patchHdl = surf(obj.ax, XMesh.*obj.RightWidth + (obj.LeftWidth + obj.ColSep), ...
                    (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + YMesh.*obj.RowHeight, ...
                    XMesh.*0, 'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat');
                hdl.ColorBar.frameHdl = plot(obj.ax, [0,1,1,0,0].*obj.RightWidth + (obj.LeftWidth + obj.ColSep), ...
                    (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + [0,0,1,1,0].*obj.RowHeight, ...
                    'Color','k', 'LineWidth',1);
                hdl.ColorBar.textHdl(1) = text(obj.ax, obj.LeftWidth + obj.ColSep, ...
                    (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + obj.RowHeight/2, ...
                    [vTxt{1},' '], 'HorizontalAlignment','right', obj.FontProp{:});
                hdl.ColorBar.textHdl(2) = text(obj.ax, obj.LeftWidth + obj.ColSep + obj.RightWidth, ...
                    (obj.tIndex - 1)*(obj.RowHeight + obj.RowSep) + obj.RowHeight/2, ...
                    [' ', vTxt{2}], 'HorizontalAlignment','left', obj.FontProp{:});
            end

            if flag
                obj.tColorList = hdl.ColorList;
            else
                obj.tColormap = hdl.ColorList;
            end
            obj.tIndex = obj.tIndex + 1;

            axis(obj.ax, 'tight');
            if nargout == 1
                varargout = {hdl};
            end
        end
    end
end