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

A = [ones_vector; weight_y; weight_y .* x_axis; weight_y .* y_axis; weight_y .* z_axis];
b = [700; 102300; 1000; 1000; 1000];

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

x0 = [];

f = -ones(1 : 36*700);
intcon = 1 : 36*700;

[x,fval,exitflag,output] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,x0);




