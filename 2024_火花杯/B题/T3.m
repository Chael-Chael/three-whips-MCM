clc
clear
CSI4=load("CSI4.mat","CSI");
CSI4=CSI4.CSI;
%%
mod_Z=abs(CSI4);
phase_Z=angle(CSI4);
matrixA=(7:127);matrixB=(131:250);
matrix=[matrixA,matrixB];
removeCols = [1:6, 128:130,251:256];
% 保留的列的索引
keepCols = setdiff(1:size(phase_Z, 2), removeCols);
% 删除指定的列
newphase_Z = phase_Z(:, keepCols);
% 保留的列的索引
keepCols = setdiff(1:size(phase_Z, 2), removeCols);
% 删除指定的列
newmod_Z = mod_Z(:, keepCols);
c=cool(24);
for i = 1:24
figure(1);
plot(matrix,newphase_Z(i,:),'color', c(i,:),'DisplayName',strcat('第',num2str(i),'条天线'),'Linewidth',1);
hold on;
end

% 初始化 k  
initial_k = 0;  
options = optimoptions('lsqnonlin', 'Display', 'off'); % 设置选项  
k_fit = lsqnonlin(@(k) Obj_Fun(k, newphase_Z, matrix), initial_k, [], [], options); 
fprintf('最优的 k 值: %f\n', k_fit);


for i = 1:24
figure(2);
plot(matrix,newmod_Z(i,:),'color', c(i,:),'DisplayName',strcat('第',num2str(i),'条天线'),'Linewidth',1);
hold on;
end

mod_Z2=abs(CSI5);
phase_Z2=angle(CSI5);
% 保留的列的索引
keepCols2 = setdiff(1:size(phase_Z2, 2), removeCols);
% 删除指定的列
newphase_Z2 = phase_Z2(:, keepCols2);
% 保留的列的索引
keepCols2 = setdiff(1:size(phase_Z2, 2), removeCols);
% 删除指定的列
newmod_Z2= mod_Z2(:, keepCols2);
c=cool(24);
for i = 1:24
figure(3);
plot(matrix,newphase_Z2(i,:),'color', c(i,:),'DisplayName',strcat('第',num2str(i),'条天线'),'Linewidth',1);
hold on;
end
for i = 1:24
figure(4);
plot(matrix,newmod_Z2(i,:),'color', c(i,:),'DisplayName',strcat('第',num2str(i),'条天线'),'Linewidth',1);
hold on;
end
