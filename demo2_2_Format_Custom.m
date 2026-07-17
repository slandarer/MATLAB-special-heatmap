%% Custom shape and auto-size custom shape

% The shape need to be in range in X:[-.5,.5], Y:[-.5,.5]; 
% The 'SData' need to be set.

% heart shape
t = linspace(0, 2*pi, 200);
x = 16*sin(t).^3./34;
y = (13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t) + 2.1)./30;
SData = [x; y];

% custom shape
figure()
Data = rand(15,15) - .5;
SHM1 = SHeatmap(Data, 'Format','cust', 'SData',SData);
SHM1.draw();

% auto-size custom shape
figure()
SHM2 = SHeatmap(Data, 'Format','acust', 'SData',SData);
SHM2.draw();
