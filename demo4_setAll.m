%% Overall decoration

% Overall decoration (整体修饰)

% + obj.setBox(___)   : 修饰边框
% + obj.setPatch(___) : 修饰图形
% + obj.setText(___)  : 修饰文本
% + obj.setFrame(___) : 修饰外轮廓

figure()
Data = rand(10, 10);

SHM = SHeatmap(Data, 'Format','pie');
SHM.draw(); 
% The container box border is set to blue (容器边框设置为蓝色)
% The drawing border is set to red (图形边框设置为红色)
SHM.setBox('Color',[0,0,.8])
SHM.setPatch('EdgeColor',[.8,0,0])


figure()
Data = rand(10, 10); Data([4, 5, 13]) = nan;

SHM = SHeatmap(Data, 'Format','sq');
SHM.draw(); 
% Set the text to blue and modify the font size (设置文本为蓝色并修改字号)
SHM.setText('Color',[0,0,.8], 'FontSize',14)
SHM.setFrame('LineWidth',2)