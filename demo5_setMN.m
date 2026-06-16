%% Decorative patch and text in row m and column n
% 修饰 m 行 n 列方块及文本
figure()
Data=rand(9,9);
Data([4,5,13]) = nan;
SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw();
% Show Text (显示文本)
SHM.setText(); 
for i=1:size(Data,1)
    for j=1:size(Data,2)
        if Data(i,j)>=.9
            SHM.setTextMN(i,j,'String','**','FontSize',20)         % 修改>=0.9方块颜色
            SHM.setPatchMN(i,j,'EdgeColor',[1,0,0],'LineWidth',2)  % 修改>=0.9方块文本为**
        end
        if isnan(Data(i,j))
            SHM.setPatchMN(i,j,'FaceColor',[.8,.6,.6]) % 修改NaN处颜色
        end
    end
end