SVR = SVarRowChart('LeftWidth',30, 'RightWidth',15);

SVR.addRow(randi([1, 100], [1, 50]), 'Title','Variable-A');
SVR.addRow(randn(1, 50), 'Title','Variable-B', 'Unit','cm', 'ColorList',slanCM(100, 32));

set_B = {'Cat','Dog','Bird'};
var_B = set_B(randi([1, 3], [1, 50]));
SVR.addRow(var_B, 'Title','Variable-C', 'Label',set_B);