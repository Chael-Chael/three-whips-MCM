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
data_new=data(:,[1,2,3,6]);
colsToStandardize = [2, 3, 6];
data_new_n=table2array(data_new(:,2:end));
data_new_nn=zscore(data_new_n);

y=pdist(data_new_nn,'cityblock');
yc=squareform(y);
z=linkage(yc);
dendrogram(z);
T=cluster(z,'maxclust',5);
for i=1:5
  tm=find(T==i);
  tm=reshape(tm,1,length(tm));
  fprintf('第%d类的有%s\n',i,int2str(tm));
end
% rowsToExtract =[1   2   3   4   5   6   7   8   9  10  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  39  40];
% B = data_new_n(rowsToExtract, :);
% y1=pdist(B,'cityblock');
% yc1=squareform(y1);
% z1=linkage(yc1);
% dendrogram(z1);
s = silhouette(data_new_nn,T); % 每个样本的轮廓值
mean_s = mean(s)  %  轮廓系数
KK = 5:10;
Mean_S = zeros(1,numel(KK));
for ii = 1:numel(KK)
    K = KK(ii);   % 簇的数量
    rng(520)  % 设置随机数种子为520，保证结果可重复
    T=cluster(z,'maxclust',K);
    s = silhouette(data_new_nn,T); % 每个样本的轮廓值
    Mean_S(ii) = mean(s);  %  轮廓系数
end
figure()
bb = bar(KK,Mean_S);
xlabel("簇的数量")
ylabel("轮廓系数")
xtips = bb.XEndPoints;
ytips = bb.YEndPoints;
labels = string(round(bb.YData,4));
text(xtips,ytips,labels,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
