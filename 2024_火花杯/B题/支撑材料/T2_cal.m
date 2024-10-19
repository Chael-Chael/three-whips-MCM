% 已知点 B 和 C 的坐标
B = [1, 1];
C = [7.3, 1];

% 已知距离 x 和 y
x = (3.57e-8)*(3e8); % 你需要根据实际问题设置x的值
y = (1.90e-8)*(3e8); % 你需要根据实际问题设置y的值

% 定义两个方程
equations = @(coords) [
    sqrt((coords(1) - B(1))^2 + (coords(2) - B(2))^2) - x;
    sqrt((coords(1) - C(1))^2 + (coords(2) - C(2))^2) - y
];

% 初始猜测值 [X0, Y0]
initial_guess = [0, 0];

% 使用 fsolve 求解方程
% options = optimoptions('fsolve', 'Display', 'off');
[solution, fval, exitflag] = fsolve(equations, initial_guess);

% 显示结果
if exitflag > 0
    fprintf('音源坐标为 (X, Y) = (%.4f, %.4f)\n', solution(1), solution(2));
else
    disp('无法找到解，请检查输入的距离值或初始猜测。');
end