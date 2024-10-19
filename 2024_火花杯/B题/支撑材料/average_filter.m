function smoothed_y = average_filter(y)  
     N = 1;  
    % 获取 y 的长度  
    len = length(y);  
    % 初始化平滑结果的矩阵  
    smoothed_y = zeros(size(y));  
    
    % 使用移动均值滤波器  
    for i = 1:len 
        % 计算平均值的起始和结束索引  
        start_idx = max(1, i - N);  
        end_idx = min(len, i + N);  
        
        % 计算当前点的移动均值  
        smoothed_y(i) = mean(y(start_idx:end_idx));  
    end  
end  


