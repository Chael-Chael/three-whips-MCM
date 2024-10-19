%% 设置导入选项并导入数据
opts = spreadsheetImportOptions("NumVariables", 6);
% 指定工作表和范围
opts.Sheet = "Sheet1";
opts.DataRange = "A2:F42";
% 指定列名称和类型
opts.VariableNames = ["ID", "predict_yield", "cost", "VarName4", "VarName5", "price"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double"];
% 导入数据
data = readtable("D:\CUMCM2024Problems\C题\工作簿1.xlsx", opts, "UseExcel", false);
%% 清除临时变量
clear opts
% data_1=data(1:16,[2,5]);
% data__1=table2array(data_1);
% R0= corrcoef(data__1);%预期销售量和种植成本之间的关系（粮食类）
% data__2=table2array(data(17:37,[2,5]));
% R1=corrcoef(data__2);%预期销售量和种植成本之间的关系（蔬菜类）
% data__3=table2array(data(38:41,[2,5]));
% R2=corrcoef(data__3);%预期销售量和种植成本之间的关系（食用菌类）
% data__4=table2array(data(1:16,[2,6]));
% R3=corrcoef(data__4);%预期销售量和销售单价之间的关系（粮食类）
% data__5=table2array(data(17:37,[2,6]));
% R4=corrcoef(data__5);%预期销售量和销售单价之间的关系（蔬菜类）
% data__6=table2array(data(38:41,[2,6]));
% R5=corrcoef(data__6);%预期销售量和销售单价之间的关系（食用菌类）
% R=[R0(1,2),R1(1,2),R2(1,2),R3(1,2),R4(1,2),R5(1,2)]
data_1_new=data(1:16,[2,5,6]);
data__1_new=table2array(data_1_new);
R0_new= corrcoef(data__1_new);%预期销售量和种植成本之间的关系（粮食类）
data__2_new=table2array(data(17:37,[2,5,6]));
R1_new=corrcoef(data__2_new);%预期销售量和种植成本之间的关系（蔬菜类）
data__3_new=table2array(data(38:41,[2,5,6]));
R2_new=corrcoef(data__3_new);%预期销售量和种植成本之间的关系（食用菌类）