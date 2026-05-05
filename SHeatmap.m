classdef SHeatmap < handle
% Copyright (c) 2023-2025, Zhaoxu Liu / slandarer
% =========================================================================
% Format
% -------------------------------------------------------------------------
% try:
%   Data = rand(15,15);
%   SHM = SHeatmap(Data,'Format','sq');
%   SHM = SHM1.draw();
% -------------------------------------------------------------------------
% 'sq'          : square (default)          : 方形(默认)
% 'pie'         : pie chart                 : 饼图
% 'donut'       ：donut chart               : 环形饼图(甜甜圈图)
% 'circ'        : circle                    : 圆形
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
% -------------------------------------------------------------------------
% see demo2_2_Format_Custom.m for detail
% 'cust'        : custom shape              : 自定义形状
% 'acust'       : auto-size custom shape    : 自带调整大小的自定义形状
% =========================================================================
% TriType
% -------------------------------------------------------------------------
% try:
%   X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1,6), ...
%                   (linspace(.5,-.7,20)').*ones(1,5), ...
%                   (linspace(.9,-.2,20)').*ones(1,4)];
%   Data = corr(X);
%   SHM = SHeatmap(Data, 'Type','sq');
%   SHM = SHM.draw();
%   SHM.setType('triu');
% -------------------------------------------------------------------------
% 'triu'   : upper triangle                  : 上三角部分
% 'tril'   : lower triangle                  : 下三角部分
% 'triu0'  : upper triangle without diagonal : 扣除对角线上三角部分
% 'tril0'  : lower triangle without diagonal : 扣除对角线下三角部分
% =========================================================================
% Update(2025-12-01):
% + 更多形状(More shapes)
% + 使用不同colormap(Draw heat maps with two colormaps)
% + 显示显著性(Displaying significance)
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2025). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2025/12/1.
% -------------------------------------------------------------------------

    properties
        ax,arginList={'Format','Parent','SData'}
        Format='sq'  
        % 'sq'          : square (default)          : 方形(默认)
        % 'pie'         : pie chart                 : 饼图
        % 'donut'       ：donut chart               : 环形饼图(甜甜圈图)
        % 'circ'        : circle                    : 圆形
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
        Data
        dfColor1=[0.9686    0.9882    0.9412;    0.9454    0.9791    0.9199;    0.9221    0.9700    0.8987;    0.8988    0.9609    0.8774;
                  0.8759    0.9519    0.8560;    0.8557    0.9438    0.8338;    0.8354    0.9357    0.8115;    0.8152    0.9276    0.7892;
                  0.7909    0.9180    0.7685;    0.7545    0.9039    0.7523;    0.7180    0.8897    0.7361;    0.6816    0.8755    0.7199;
                  0.6417    0.8602    0.7155;    0.5962    0.8430    0.7307;    0.5507    0.8258    0.7459;    0.5051    0.8086    0.7610;
                  0.4596    0.7873    0.7762;    0.4140    0.7620    0.7914;    0.3685    0.7367    0.8066;    0.3230    0.7114    0.8218;
                  0.2837    0.6773    0.8142;    0.2483    0.6378    0.7929;    0.2129    0.5984    0.7717;    0.1775    0.5589    0.7504;
                  0.1421    0.5217    0.7314;    0.1066    0.4853    0.7132;    0.0712    0.4488    0.6950;    0.0358    0.4124    0.6768;
                  0.0314    0.3724    0.6364;    0.0314    0.3319    0.5929;    0.0314    0.2915    0.5494;    0.0314    0.2510    0.5059]
        dfColor2=[0.6196    0.0039    0.2588;    0.6892    0.0811    0.2753;    0.7588    0.1583    0.2917;    0.8283    0.2354    0.3082;
                  0.8706    0.2966    0.2961;    0.9098    0.3561    0.2810;    0.9490    0.4156    0.2658;    0.9660    0.4932    0.2931;
                  0.9774    0.5755    0.3311;    0.9887    0.6577    0.3690;    0.9930    0.7266    0.4176;    0.9943    0.7899    0.4707;
                  0.9956    0.8531    0.5238;    0.9968    0.9020    0.5846;    0.9981    0.9412    0.6503;    0.9994    0.9804    0.7161;
                  0.9842    0.9937    0.7244;    0.9526    0.9810    0.6750;    0.9209    0.9684    0.6257;    0.8721    0.9486    0.6022;
                  0.7975    0.9183    0.6173;    0.7228    0.8879    0.6325;    0.6444    0.8564    0.6435;    0.5571    0.8223    0.6448;
                  0.4698    0.7881    0.6460;    0.3868    0.7461    0.6531;    0.3211    0.6727    0.6835;    0.2553    0.5994    0.7139;
                  0.2016    0.5261    0.7378;    0.2573    0.4540    0.7036;    0.3130    0.3819    0.6694;    0.3686    0.3098    0.6353]
        Colormap;maxV;Parent=[];SData=[];Colorbar
        patchHdl;boxHdl;pieHdl;textHdl
        % 修改为上下三角
        Type='full';VarName;RLabelHdl;CLabelHdl
    end
    methods
        function obj=SHeatmap(varargin)
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else  
            end
            obj.Data=varargin{1};varargin(1)=[];
            obj.maxV=max(max(abs(obj.Data)));
            % 获取其他数据
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                    obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            % 设置配色
            if any(any(obj.Data<0))
                obj.Colormap=obj.dfColor2;
                % tX=linspace(0,1,size(obj.Colormap,1));
                % tXi=linspace(0,1,256);
                % tR=interp1(tX,obj.Colormap(:,1),tXi);
                % tG=interp1(tX,obj.Colormap(:,2),tXi);
                % tB=interp1(tX,obj.Colormap(:,3),tXi);
                % obj.Colormap=[tR(:),tG(:),tB(:)];
            else
                obj.Colormap=obj.dfColor1(end:-1:1,:);
            end
        end
        function obj=draw(obj)
            if isempty(obj.Parent)
                obj.ax=gca;
            else
                obj.ax=obj.Parent;
            end
            obj.ax.NextPlot='add';
            obj.ax.Box='on';
            obj.ax.FontName='Times New Roman';
            obj.ax.FontSize=12;
            obj.ax.LineWidth=.8;
            obj.ax.XLim=[.5,size(obj.Data,2)+.5];
            obj.ax.YLim=[.5,size(obj.Data,1)+.5];
            obj.ax.YDir='reverse';
            obj.ax.TickDir='out';
            obj.ax.TickLength=[0.002,0.002];
            obj.ax.DataAspectRatio=[1,1,1];
            obj.ax.YTick=1:size(obj.Data,1);
            obj.ax.XTick=1:size(obj.Data,2);
            colormap(obj.ax,obj.Colormap)
            obj.Colorbar = colorbar(obj.ax);

            if any(any(obj.Data<0))
                try caxis(obj.ax,obj.maxV.*[-1,1]),catch,end
                try clim(obj.ax,obj.maxV.*[-1,1]),catch,end
            else
                try caxis(obj.ax,obj.maxV.*[0,1]),catch,end
                try clim(obj.ax,obj.maxV.*[0,1]),catch,end
            end

            % 调整初始界面大小
            
            fig=obj.ax.Parent;
            if strcmp(get(fig,'Type'),'figure')
                fig.Color=[1,1,1];
                if max(fig.Position(3:4))<600&&strcmp(fig.Units,'pixels')
                    fig.Position(3:4)=[1.6,1.8].*fig.Position(3:4);
                    fig.Position(1:2)=fig.Position(1:2)./4;
                end
            end

            bX1=repmat([.5,size(obj.Data,2)+.5,nan],[size(obj.Data,1)+1,1])';
            bY1=repmat((.5:1:(size(obj.Data,1)+.5))',[1,3])';
            bX2=repmat((.5:1:(size(obj.Data,2)+.5))',[1,3])';
            bY2=repmat([.5,size(obj.Data,1)+.5,nan],[size(obj.Data,2)+1,1])';
            obj.boxHdl=plot(obj.ax,[bX1(:);bX2(:)],[bY1(:);bY2(:)],'LineWidth',.8,'Color',[1,1,1].*.85);
            if isequal(obj.Format,'sq')
                set(obj.boxHdl,'Color',[1,1,1,0])
            end

            % disp(char([64 97 117 116 104 111 114 32 58 32,...
            %      115 108 97 110 100 97 114 101 114]))
            baseT=linspace(0,2*pi,200);
            hexT=linspace(0,2*pi,7);
            starT=linspace(0,2*pi,11)+pi/10;
            thetaMat=[1,-1;1,1].*sqrt(2)./2;

            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)    
                    if isnan(obj.Data(row,col))
                        obj.patchHdl(row,col)=fill(obj.ax,[-.5,.5,.5,-.5].*.98+col,[-.5,-.5,.5,.5].*.98+row,[.8,.8,.8],'EdgeColor','none');
                        obj.pieHdl(row,col)=fill(obj.ax,[0,0,0,0],[0,0,0,0],[0,0,0]);
                        obj.textHdl(row,col)=text(obj.ax,col,row,'×','FontName','Times New Roman','HorizontalAlignment','center','FontSize',20);
                    else
                        tRatio=abs(obj.Data(row,col))./obj.maxV;
                        switch obj.Format
                            case 'sq'
                                obj.patchHdl(row,col)=fill(obj.ax,[-.5,.5,.5,-.5].*.98+col,[-.5,-.5,.5,.5].*.98+row,...
                                    obj.Data(row,col),'EdgeColor','none');
                            case 'asq'
                                obj.patchHdl(row,col)=fill(obj.ax,[-.5,.5,.5,-.5].*.98.*tRatio+col,[-.5,-.5,.5,.5].*.98.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor','none');
                            case 'pie'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.pieHdl(row,col)=fill(obj.ax,baseCircX+col,baseCircY+row,...
                                    [1,1,1],'EdgeColor',[1,1,1].*.3,'LineWidth',.8);
                                baseTheta=linspace(pi/2,pi/2+obj.Data(row,col)./obj.maxV.*2.*pi,200);
                                basePieX=[0,cos(baseTheta).*.92.*.5];
                                basePieY=[0,sin(baseTheta).*.92.*.5];
                                obj.patchHdl(row,col)=fill(obj.ax,basePieX+col,-basePieY+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'circ'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.patchHdl(row,col)=fill(obj.ax,baseCircX+col,baseCircY+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case 'acirc'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.patchHdl(row,col)=fill(obj.ax,baseCircX.*tRatio+col,baseCircY.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case 'oval'
                                tValue=obj.Data(row,col)./obj.maxV;
                                baseA=1+(tValue<=0).*tValue;
                                baseB=1-(tValue>=0).*tValue;
                                baseOvalX=cos(baseT).*.98.*.5.*baseA;
                                baseOvalY=sin(baseT).*.98.*.5.*baseB;
                                baseOvalXY=thetaMat*[baseOvalX;baseOvalY];
                                obj.patchHdl(row,col)=fill(obj.ax,baseOvalXY(1,:)+col,-baseOvalXY(2,:)+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'hex'
                                obj.patchHdl(row,col)=fill(obj.ax,cos(hexT).*.5.*.98.*tRatio+col,sin(hexT).*.5.*.98.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            % 2025-12-01 更新
                            case 'star'
                                tValue=obj.Data(row,col)./obj.maxV;
                                baseStarX=cos(starT).*.92.*.5.*tValue;
                                baseStarY=sin(starT).*.92.*.5.*tValue;
                                baseStarX(1:2:end) = baseStarX(1:2:end).*.5;
                                baseStarY(1:2:end) = baseStarY(1:2:end).*.5;
                                obj.patchHdl(row,col)=fill(obj.ax,baseStarX+col,baseStarY+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case {'tril','trill'}
                                obj.patchHdl(row,col)=fill(obj.ax,[-.5,.5,-.5]+col,[.5,.5,-.5]+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case {'triu','triur'}
                                obj.patchHdl(row,col)=fill(obj.ax,[-.5,.5,.5]+col,[-.5,.5,-.5]+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);   
                            case {'triul'}
                                obj.patchHdl(row,col)=fill(obj.ax,[.5,-.5,-.5]+col,[-.5,-.5,.5]+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case {'trilr'}
                                obj.patchHdl(row,col)=fill(obj.ax,[-.5,.5,.5]+col,[.5,.5,-.5]+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case 'donut'
                                baseCircX=cos(baseT-pi/2).*.92.*.5;
                                baseCircY=sin(baseT-pi/2).*.92.*.5;
                                obj.pieHdl(row,col)=fill(obj.ax,[baseCircX,baseCircX(end:-1:1).*.5]+col,[baseCircY,baseCircY(end:-1:1).*.5]+row,...
                                    [1,1,1],'EdgeColor',[1,1,1].*.3,'LineWidth',.8);
                                baseTheta=linspace(pi/2,pi/2+obj.Data(row,col)./obj.maxV.*2.*pi,200);
                                basePieX=cos(baseTheta).*.92.*.5;
                                basePieY=sin(baseTheta).*.92.*.5;
                                obj.patchHdl(row,col)=fill(obj.ax,[basePieX,basePieX(end:-1:1).*.5]+col,-[basePieY,basePieY(end:-1:1).*.5]+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'cust'
                                obj.patchHdl(row,col)=fill(obj.ax,obj.SData(1,:)+col,-obj.SData(2,:)+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'acust'
                                obj.patchHdl(row,col)=fill(obj.ax,obj.SData(1,:).*tRatio+col,-obj.SData(2,:).*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'bcirc'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.pieHdl(row,col)=fill(obj.ax,baseCircX+col,baseCircY+row,...
                                    [1,1,1],'EdgeColor',[1,1,1].*.3,'LineWidth',.8);
                                obj.patchHdl(row,col)=fill(obj.ax,baseCircX.*tRatio+col,baseCircY.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);


                        end
                        obj.textHdl(row,col)=text(obj.ax,col,row,sprintf('%.2f',obj.Data(row,col)),'FontName','Times New Roman','HorizontalAlignment','center','Visible','off');
                    end
                end
            end
            % -------------------------------------------------------------
            for i=1:length(obj.Data)
                obj.VarName{i}=['Var-',num2str(i)];
            end
            for row=1:size(obj.Data,1)
                obj.RLabelHdl(row)=text(obj.ax,.5-.25,row,...
                    obj.VarName{row},'HorizontalAlignment','right',...
                    'FontName','Cambria','FontSize',12,'Visible','off');
            end
            for col=1:size(obj.Data,2)
                obj.CLabelHdl(col)=text(obj.ax,col,.5-.25,...
                    obj.VarName{col},'HorizontalAlignment','left',...
                    'FontName','Cambria','FontSize',12,'Rotation',30,'Visible','off');
            end
        end
        % 修饰文本
        function setText(obj,varargin)
            graymap=mean(get(obj.ax,'Colormap'),2);
            climit=get(obj.ax,'CLim');
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)     
                    set(obj.textHdl(row,col),'Visible','on','Color',...
                        [1,1,1].*(interp1(linspace(climit(1),climit(2),size(graymap,1)),graymap,obj.Data(row,col))<.5),varargin{:})
                end
            end
            switch obj.Type
                case 'triu'
                    for row=1:size(obj.Data,1)
                        for col=1:(row-1)
                            set(obj.textHdl(row,col),'Visible','off')
                        end
                    end
                case 'tril'
                    for col=1:size(obj.Data,2)
                        for row=1:(col-1)
                            set(obj.textHdl(row,col),'Visible','off')
                        end
                    end
                case 'triu0'
                    for row=1:size(obj.Data,1)
                        for col=1:(row)
                            set(obj.textHdl(row,col),'Visible','off')
                        end
                    end
                case 'tril0'
                    for col=1:size(obj.Data,2)
                        for row=1:(col)
                            set(obj.textHdl(row,col),'Visible','off')
                        end
                    end
            end
        end
        function setTextMN(obj,m,n,varargin)
            set(obj.textHdl(m,n),varargin{:})
        end
        % 设置图形样式
        function setPatch(obj,varargin)
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)   
                    if ~isnan(obj.Data(row,col))
                        set(obj.patchHdl(row,col),varargin{:})
                        if isequal(obj.Format,'pie')||isequal(obj.Format,'donut')||isequal(obj.Format,'bcirc')
                            set(obj.pieHdl(row,col),varargin{:})
                        end
                    end
                end
            end
        end
        function setPatchMN(obj,m,n,varargin)
            set(obj.patchHdl(m,n),varargin{:})
            if isequal(obj.Format,'pie')||isequal(obj.Format,'donut')||isequal(obj.Format,'bcirc')
                set(obj.pieHdl(m,n),varargin{:})
            end
        end
        % 设置框样式
        function setBox(obj,varargin)
            set(obj.boxHdl,varargin{:})
        end
        % 调整上下三角
        function obj=setType(obj,Type)
            if size(obj.Data,1)==size(obj.Data,2)
            obj.Type=Type;
            obj.ax.XColor='none';
            obj.ax.YColor='none';
            obj.ax.YAxisLocation='right';
            % obj.ax.YTickLabel='slandarer';
            bX1=repmat([.5,size(obj.Data,2)+.5,nan],[size(obj.Data,1)+1,1])';
            bY1=repmat((.5:1:(size(obj.Data,1)+.5))',[1,3])';
            bX2=repmat((.5:1:(size(obj.Data,2)+.5))',[1,3])';
            bY2=repmat([.5,size(obj.Data,1)+.5,nan],[size(obj.Data,2)+1,1])';
            for n=1:size(obj.Data,1)
                set(obj.RLabelHdl(n),'Visible','on');
                set(obj.CLabelHdl(n),'Visible','on');
            end
            switch obj.Type
                case 'triu'
                    for row=1:size(obj.Data,1)
                        for col=1:(row-1)
                            set(obj.patchHdl(row,col),'Visible','off')
                            set(obj.textHdl(row,col),'Visible','off')
                            if isequal(obj.Format,'pie')||isequal(obj.Format,'donut')||isequal(obj.Format,'bcirc')
                                set(obj.pieHdl(row,col),'Visible','off')
                            end
                        end
                    end
                    bX1(1,2:end)=bX1(1,2:end)+(0:size(obj.Data,1)-1);
                    bY2(2,:)=[1.5:1:(size(obj.Data,1)+.5),(size(obj.Data,1)+.5)];
                    set(obj.boxHdl,'XData',[bX1(:);bX2(:)],'YData',[bY1(:);bY2(:)])
                    for n=1:size(obj.Data,1)
                        set(obj.RLabelHdl(n),'Position',[.25-1+n,n,0]);
                        set(obj.CLabelHdl(n),'Position',[n,.25,0]);
                    end
                case 'tril'
                    for col=1:size(obj.Data,2)
                        for row=1:(col-1)
                            set(obj.patchHdl(row,col),'Visible','off')
                            set(obj.textHdl(row,col),'Visible','off')
                            if isequal(obj.Format,'pie')||isequal(obj.Format,'donut')||isequal(obj.Format,'bcirc')
                                set(obj.pieHdl(row,col),'Visible','off')
                            end
                        end
                    end
                    bX1(2,1:end-1)=bX1(2,1:end-1)-(size(obj.Data,1)-1:-1:0);
                    bY2(1,:)=[.5,.5:1:(size(obj.Data,1)-.5)];
                    set(obj.boxHdl,'XData',[bX1(:);bX2(:)],'YData',[bY1(:);bY2(:)])
                    for n=1:size(obj.Data,1)
                        set(obj.RLabelHdl(n),'Position',[.25,n,0]);
                        set(obj.CLabelHdl(n),'Position',[n,.25-1+n,0]);
                    end
                case 'triu0'
                    for row=1:size(obj.Data,1)
                        for col=1:(row)
                            set(obj.patchHdl(row,col),'Visible','off')
                            set(obj.textHdl(row,col),'Visible','off')
                            if isequal(obj.Format,'pie')||isequal(obj.Format,'donut')||isequal(obj.Format,'bcirc')
                                set(obj.pieHdl(row,col),'Visible','off')
                            end
                        end
                    end
                    bX1(1,:)=bX1(1,:)+1;
                    bX1(1,2:end)=bX1(1,2:end)+(0:size(obj.Data,1)-1);
                    bY2(2,:)=[1.5:1:(size(obj.Data,1)+.5),(size(obj.Data,1)+.5)]-1;
                    set(obj.boxHdl,'XData',[bX1(:);bX2(:)],'YData',[bY1(:);bY2(:)])
                    for n=1:size(obj.Data,1)
                        set(obj.RLabelHdl(n),'Position',[.25+n,n,0]);
                        set(obj.CLabelHdl(n),'Position',[n,.25,0]);
                    end
                    set(obj.CLabelHdl(1),'Visible','off');
                    set(obj.RLabelHdl(size(obj.Data,1)),'Visible','off');
                case 'tril0'
                    for col=1:size(obj.Data,2)
                        for row=1:(col)
                            set(obj.patchHdl(row,col),'Visible','off')
                            set(obj.textHdl(row,col),'Visible','off')
                            if isequal(obj.Format,'pie')||isequal(obj.Format,'donut')||isequal(obj.Format,'bcirc')
                                set(obj.pieHdl(row,col),'Visible','off')
                            end
                        end
                    end
                    bX1(2,:)=bX1(2,:)-1;
                    bX1(2,1:end-1)=bX1(2,1:end-1)-(size(obj.Data,1)-1:-1:0);
                    bY2(1,:)=[.5,.5:1:(size(obj.Data,1)-.5)]+1;
                    set(obj.boxHdl,'XData',[bX1(:);bX2(:)],'YData',[bY1(:);bY2(:)])
                    for n=1:size(obj.Data,1)
                        set(obj.RLabelHdl(n),'Position',[.25,n,0]);
                        set(obj.CLabelHdl(n),'Position',[n,.25+n,0]);
                    end
                    set(obj.RLabelHdl(1),'Visible','off');
                    set(obj.CLabelHdl(size(obj.Data,1)),'Visible','off');
            end
            end
        end
        % 设置变量标签
        function setVarName(obj,VarName)
            obj.VarName=VarName;VarNameLen=length(obj.VarName);
            for n=1:size(obj.Data,1)
                set(obj.RLabelHdl(n),'String',obj.VarName{mod(n-1,VarNameLen)+1})
                set(obj.CLabelHdl(n),'String',obj.VarName{mod(n-1,VarNameLen)+1})
            end
        end
        function setRowLabel(obj,varargin)
            for n=1:size(obj.Data,1)
                set(obj.RLabelHdl(n),varargin{:})
            end
        end
        function setColLabel(obj,varargin)
            for n=1:size(obj.Data,2)
                set(obj.CLabelHdl(n),varargin{:})
            end
        end
        % 2023-05-28 更新
        function setTextFormat(obj,func)
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)
                    if ~isnan(obj.Data(row,col))
                        tStr=func(obj.Data(row,col));
                        set(obj.textHdl(row,col),'String',tStr)
                    end
                end
            end
        end
        % 2025-12-01 更新
        function freezeColors(obj)
            climit=get(obj.ax,'CLim');
            cmap=get(obj.ax,'Colormap');
            values=linspace(climit(1),climit(2),size(cmap,1)+1);
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)
                    tind=sum(obj.Data(row,col)>=values);
                    tind(tind<=0)=1;
                    tind(tind>size(cmap,1))=size(cmap,1);
                    set(obj.patchHdl(row,col), 'FaceColor',cmap(tind,:))
                end
            end
            obj.Colorbar.Colormap = cmap;
            obj.Colorbar.Limits = climit;
            obj.Colorbar.Position = obj.Colorbar.Position + [.03,0,0,0];
        end

        function showStars(obj, pval, varargin)
            starobj.Levels = [0.05, 0.01, 0.001];
            starobj.CorrLabel = 'on';
            vararginList2 = {'Levels', 'CorrLabel'};
            for i=1:2:(length(varargin)-1)
                tid=ismember(vararginList2,varargin{i});
                if any(tid)
                    starobj.(vararginList2{tid})=varargin{i+1};
                end
            end
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)
                    if ~isnan(obj.Data(row,col))
                        if strcmp(starobj.CorrLabel, 'on')
                            tStr=get(obj.textHdl(row,col),'String');
                            set(obj.textHdl(row,col),'String',{obj.pval2stars(pval(row,col), starobj.Levels);tStr})
                        else
                            set(obj.textHdl(row,col),'String',obj.pval2stars(pval(row,col), starobj.Levels))
                        end
                    end
                end
            end
        end

        function stars = pval2stars(~, pval, levels)
            if nargin < 2
                levels = [0.05, 0.01, 0.001];
            end
            stars = char(ones(1, sum(pval < levels)).*42);
        end
    end
% Copyright (c) 2023-2025, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2025/12/1.
% -------------------------------------------------------------------------
end