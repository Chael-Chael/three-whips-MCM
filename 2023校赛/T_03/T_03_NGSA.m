clc
clear

%导入数据
data = readmatrix("C:\Users\huawei\Downloads\three-whips-MCM\2023校赛\B\B.csv");

count = data(: , 1)';
weight = data(: , 2)';
volume = data(: , 3)';

x_axis = ones(1, 36);
x_axis([1:9, 19:27]) = -1;
x_axis = kron(x_axis, ones(1, 700));

y_axis = (1:36) - 5 - 9 * floor((0:35) / 9);
y_axis = kron(y_axis, ones(1, 700));

z_axis = ones(1,36);
z_axis(19:36) = -1;
z_axis = kron(z_axis, ones(1, 700));

%设定NSGA参数
fitnessfcn = @getFit;  %定义适应函数
nvars = 36*700;  %定义变量个数

%设置规划
%约束条件lb <= x <= ub
%约束为0-1变量
lb = zeros(1, 36*700);
ub = ones(1, 36*700);

%约束条件A * x <= b
%对于总体的约束矩阵
weight_y = repmat(weight, 1, 36);
volume_y = repmat(volume, 1, 36);
ones_vector = ones(1, 36*700);

A = [ones_vector; weight_y];
b = [700; 102300];

%对于每行的约束矩阵
for i = 1:36
    container_row = zeros(1, 36*700);
    container_row((i-1)*700 + 1 : i*700) = 1;
    container_weight = container_row .* weight_y;
    container_volume = container_row .* volume_y;
    A = [A; container_weight; container_volume];
    b = [b; 6804; 12.64];
end


%对于每列的约束矩阵
for j = 1:700
    container_col = zeros(1, 36*700);
    container_col(j:700:end) = 1;
    A = [A; container_col; - container_col];
    b = [b; 1; 0];
end

%对于
%Aeq*x = beq x
Aeq = [];
beq = [];

nonlcon = [];
intcon = 1 : 36*700;
%设置求解器
% 创建遗传算法的选项
options = optimoptions('gamultiobj', ...
    'ParetoFraction', 0.3, ...
    'PopulationSize', 36*700*5, ...
    'Generations', 200, ...
    'StallGenLimit', 200, ...
    'TolFun', 1e-5, ...
    'PlotFcn', @gaplotpareto);

[x,fval,exitflag,output,population,scores] = gamultiobj(fitnessfcn,nvars,A,b,Aeq,beq,lb,ub,nonlcon,intcon,options);

plot(fval(:,1),-fval(:,2),'pr')
xlabel('f_1(x)')
ylabel('f_2(x)')
title('Pareto front')
grid on


function objectives = getObj(x, weight, x_axis, y_axis, z_axis)
    obj1 = sum(x .* weight .* x_axis)^2 + sum(x .* weight .* y_axis)^2 + sum(x .* weight .* z_axis)^2;
    obj2 = -sum(x);

    objectives = [obj1, obj2];
end

function fitness = getFit(x)
    fitness = getObj(x, weight, x_axis, y_axis, z_axis);
end