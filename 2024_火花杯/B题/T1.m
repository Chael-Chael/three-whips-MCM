mod_Z=abs(CSI);
phase_Z=angle(CSI);
Z_eform=mod_Z.*exp(phase_Z*1i);
disp(['指数形式的复数矩阵: ', num2str(Z_eform)]);
%% 
matrix=(1:256);
plot(matrix,phase_Z(1,:),'b-');
matrixA=(7:127);matrixB=(131:250);
matrix=[matrixA,matrixB];
removeCols = [1:6, 128:130,251:256];
% 保留的列的索引
keepCols = setdiff(1:size(phase_Z, 2), removeCols);
% 删除指定的列
newphase_Z = phase_Z(:, keepCols);
keepCols = setdiff(1:size(mod_Z, 2), removeCols);
% 删除指定的列
newmod_Z = mod_Z(:, keepCols);
mdl1= fitlm(matrix, newphase_Z(1,:));
mdl2= fitlm(matrix, newphase_Z(2,:));
plot(matrix,newphase_Z(1,:),'b-');
plot(matrix,newmod_Z(1,:),'b-');
%% 

