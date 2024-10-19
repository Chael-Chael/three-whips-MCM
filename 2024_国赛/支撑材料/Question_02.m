clc, clear, close all
% 文件读取
%属性文件
data_land = readtable('附件1.xlsx', 'Sheet', '乡村的现有耕地', range='A2:C55');
data_land.Properties.VariableNames = {'land_id', 'land_type', 'land_area'};
data_plant = readtable('附件1.xlsx', 'Sheet', '乡村种植的农作物', range='A2:C42');
data_plant.Properties.VariableNames = {'plant_id', 'plant_name', 'plant_type'};
%23年数据文件
data_plan = readtable('附件2.xlsx', 'Sheet','2023年的农作物种植情况', range='A2:F88');
for i = 1:length(data_plan{:,1})  
    if (data_plan{i,1} == "")  
        data_plan{i,1} = data_plan{i-1,1};
    end
end
data_plan.Properties.VariableNames = {'land_id','plant_id',' plant_name', 'plant_type', 'planted_area', 'planted_time'};
data_plan = innerjoin(data_land, data_plan, 'LeftKeys', 1, 'RightKeys', 1 ,'LeftVariables',[1,2]);

data_stat = readtable('附件2.xlsx', 'Sheet','2023年统计的相关数据', range='A2:H108');
data_stat.Properties.VariableNames = {'id','plant_id',' plant_name', 'land_type', 'planted_time', 'yield_acre','cost_acre','price_range'};

insert_block = data_stat(65:82,:);
insert_block.land_type = repmat({'智慧大棚'}, height(insert_block), 1);
data_stat_1 = data_stat(1:90,:);
data_stat_2 = data_stat(90:107,:);
data_stat = [data_stat_1; insert_block; data_stat_2];

interval_column = data_stat{:, 'price_range'};
data_price = zeros(size(interval_column));
for i = 1:length(interval_column)
    interval_str = interval_column{i};
    bounds = str2double(strsplit(interval_str, '-'));
    avg_price = mean(bounds);
    data_price(i) = avg_price;
end
data_stat = [data_stat, array2table(data_price)];

data_23 = innerjoin(data_plan, data_stat, 'LeftKeys', {'plant_id','land_type','planted_time'}, 'RightKeys', {'plant_id','land_type','planted_time'}, 'LeftVariables',[3,4,5,1,2,6], 'RightVariables', 5:8);
data_23.Properties.VariableNames = {'plant_id', 'plant_name', 'plant_type', 'land_id', 'land_type', 'planted_area', 'planted_time', 'yield_acre', 'cost_acre', 'price_range'};
data_23 = sortrows(data_23, {'plant_id', 'land_id'}, {'ascend', 'ascend'});

% 提取平均值
interval_column = data_23{:, 'price_range'};
data_price = zeros(size(interval_column));
for i = 1:length(interval_column)
    interval_str = interval_column{i};
    bounds = str2double(strsplit(interval_str, '-'));
    avg_price = mean(bounds);
    data_price(i) = avg_price;
end

data_gain = (data_price .* data_23{:,'yield_acre'}) - data_23{:,'cost_acre'};%获取每亩收益
data_yield = data_23{:,'planted_area'} .* data_23{:,'yield_acre'};%获取产量
data_23 = [data_23, array2table(data_price), array2table(data_gain), array2table(data_yield)];
data_sales = groupsummary(data_23, 'plant_id', 'sum', 'data_yield');

% 问题一求解

%条件约束矩阵构造
%种植面积矩阵
constr_area_1 = cell(82,3);
j = 0;
for i = 1:size(data_land, 1)
    id = data_land{i, 1};
    land_type = data_land{i, 2};
    value = data_land{i, 3};
    if strcmp(land_type, '水浇地') || strcmp(land_type, '普通大棚') || strcmp(land_type, '智慧大棚')
        j = j+1;
        constr_area_1(i, :) = {strcat(id, '-1'), land_type, value}; 
        constr_area_1(54+j, :) = {strcat(id, '-2'), land_type, value}; 
    else
        constr_area_1(i, :) = {strcat(id, '-1'), land_type, value}; 
    end
end
constr_area_1 = cell2table(constr_area_1);
constr_area = repmat((constr_area_1{:,3})',41,1);

%亩产量矩阵
constr_yield_acre = zeros(41, 82);
data_stat = sortrows(data_stat, {'plant_id','planted_time'}, {'ascend','ascend'});
for i = 1:size(data_stat, 1)
    plant_id = data_stat{i, 2};
    land_type = data_stat{i, 4};
    planted_time = data_stat{i, 5};
    yield_acre = data_stat{i,"yield_acre"};
   
    if strcmp(land_type, '平旱地')
        constr_yield_acre(plant_id, 1:6) = repmat(yield_acre, 1, 6); 
    elseif strcmp(land_type, '梯田')
        constr_yield_acre(plant_id, 7:20) = repmat(yield_acre, 1, 14); 
    elseif strcmp(land_type, '山坡地')
        constr_yield_acre(plant_id, 21:26) = repmat(yield_acre, 1, 6); 
    elseif strcmp(land_type, '水浇地') 
        if strcmp(planted_time, '单季')
            constr_yield_acre(plant_id, 27:34) = repmat(yield_acre, 1, 8); 
        elseif strcmp(planted_time, '第一季')
            constr_yield_acre(plant_id, 27:34) = repmat(yield_acre, 1, 8); 
        elseif strcmp(planted_time, '第二季')
            constr_yield_acre(plant_id, 55:62) = repmat(yield_acre, 1, 8); 
        end
    elseif strcmp(land_type, '普通大棚') 
        if strcmp(planted_time, '第一季')
            constr_yield_acre(plant_id, 35:50) = repmat(yield_acre, 1, 16); 
        elseif strcmp(planted_time, '第二季')
            constr_yield_acre(plant_id, 63:78) = repmat(yield_acre, 1, 16); 
        end
    elseif strcmp(land_type, '智慧大棚')
        if strcmp(planted_time, '第一季')
            constr_yield_acre(plant_id, 51:54) = repmat(yield_acre, 1, 4); 
        elseif strcmp(planted_time, '第二季')
            constr_yield_acre(plant_id, 79:82) = repmat(yield_acre, 1, 4); 
        end
    end
end

constr_yield_acre_min=zeros(41,82);
constr_yield_acre_max=zeros(41,82);
constr_yield_acre_min=constr_yield_acre.*0.9;
constr_yield_acre_max=constr_yield_acre.*1.1;

%每亩成本矩阵
constr_cost_acre = zeros(41, 82);
for i = 1:size(data_stat, 1)
    plant_id = data_stat{i, 2};
    land_type = data_stat{i, 4};
    planted_time = data_stat{i, 5};
    cost_acre = data_stat{i,"cost_acre"};
   
    if strcmp(land_type, '平旱地')
        constr_cost_acre(plant_id, 1:6) = repmat(cost_acre, 1, 6); 
    elseif strcmp(land_type, '梯田')
        constr_cost_acre(plant_id, 7:20) = repmat(cost_acre, 1, 14); 
    elseif strcmp(land_type, '山坡地')
        constr_cost_acre(plant_id, 21:26) = repmat(cost_acre, 1, 6); 
    elseif strcmp(land_type, '水浇地') 
        if strcmp(planted_time, '单季')
            constr_cost_acre(plant_id, 27:34) = repmat(cost_acre, 1, 8); 
        elseif strcmp(planted_time, '第一季')
            constr_cost_acre(plant_id, 27:34) = repmat(cost_acre, 1, 8); 
        elseif strcmp(planted_time, '第二季')
            constr_cost_acre(plant_id, 55:62) = repmat(cost_acre, 1, 8); 
        end
    elseif strcmp(land_type, '普通大棚') 
        if strcmp(planted_time, '第一季')
            constr_cost_acre(plant_id, 35:50) = repmat(cost_acre, 1, 16); 
        elseif strcmp(planted_time, '第二季')
            constr_cost_acre(plant_id, 63:78) = repmat(cost_acre, 1, 16); 
        end
    elseif strcmp(land_type, '智慧大棚')
        if strcmp(planted_time, '第一季')
            constr_cost_acre(plant_id, 51:54) = repmat(cost_acre, 1, 4); 
        elseif strcmp(planted_time, '第二季')
            constr_cost_acre(plant_id, 79:82) = repmat(cost_acre, 1, 4); 
        end
        end
end

constr_cost_acre_new=constr_cost_acre.*1.05;%成本

% 预期销量矩阵
constr_sales = (data_sales{:,3});
[uniqueValues, index] = unique(data_stat(:,2));
constr_price = data_stat(index,'data_price');
constr_price_new_min=constr_price;
constr_price_new_max=constr_price;
constr_price_new_min(17:37,1)=constr_price(17:37,1).*1.05;
constr_price_new_min(38:40,1)=constr_price(38:40,1).*0.95;
constr_price_new_min(41,1)=constr_price(41,1).*0.95;
constr_price_new_max(17:37,1)=constr_price(17:37,1).*1.05;
constr_price_new_max(38:40,1)=constr_price(38:40,1).*0.99;
constr_price_new_max(41,1)=constr_price(41,1).*0.95;

constr_sales_new_min=constr_sales;constr_sales_new_min(6:7,1)=constr_sales(6:7,1).*1.05;
constr_sales_new_min(1:5, :) = constr_sales_new_min(1:5, :) .* 0.95;
constr_sales_new_min(8:41, :) = constr_sales_new_min(8:41, :) .* 0.95;
constr_sales_new_max=constr_sales;constr_sales_new_max(6:7,1)=constr_sales(6:7,1).*1.1;
constr_sales_new_max(1:5, :) = constr_sales_new_max(1:5, :) .* 1.05;
constr_sales_new_max(8:41, :) = constr_sales_new_max(8:41, :) .* 1.05;%预测销量

%种植可能性矩阵
constr_prop = zeros(41, 82);
constr_prop(1:15,1:26) = 1; %约束粮食（除水稻）
constr_prop(16,27:34) = 0;%约束水稻(不种水稻)
constr_prop(17:34,[27:54,79:82]) = 1;%约束除了大白红以外的蔬菜
constr_prop(35:37,55:62) = 1;%约束大白红
constr_prop(38:41,63:78) = 1;%约束食用菌

%此前矩阵
%23年矩阵
idx_land = constr_area_1{:,1};
data_23_1 = sortrows(data_23, {'land_id', 'planted_time'}, {'ascend', 'ascend'});
year_23 = zeros(41,82);

for i = 1:height(data_23_1)
    land_id =  data_23_1.land_id{i};
    land_type = data_23_1.land_type{i}; 
    planted_time = data_23_1.planted_time{i}; 
    
    if strcmp(land_type, '梯田') || strcmp(land_type, '山坡地') || strcmp(land_type, '平旱地')
        data_23_1.land_id{i} = strcat(land_id, '-1'); 
    elseif strcmp(land_type, '水浇地') && (strcmp(planted_time, '单季') || strcmp(planted_time, '第一季'))
        data_23_1.land_id{i} = strcat(land_id, '-1');
    elseif strcmp(planted_time, '第一季')
        data_23_1.land_id{i} = strcat(land_id, '-1');
    elseif strcmp(planted_time, '第二季')
        data_23_1.land_id{i} = strcat(land_id, '-2');
    end
end

for i = 1:height(data_23_1)
    [~, id] = ismember(data_23_1{i,'land_id'}, idx_land);
    year_23(data_23_1{i,'plant_id'},id) = 1;
end

revenue_23 = sum( constr_sales .* constr_price.data_price ) - sum(sum(year_23 .* constr_area .* constr_cost_acre));

year = cell(1,9);
plan = cell(1,7);
revenue = cell(1,8);

year{1} = zeros(41,82);
year{2} = year_23;
revenue{1} = revenue_23;

xidx = (constr_area_1{:,1})';
yidx = (data_plant{:,2})';
figure('Position',[100,100,1200,600])
heatmap(xidx,yidx,year_23)
colormap([1,1,1;0.2,0.2,0.2])

%%
for year_now = 1:7
    %不能连续种植
    year_pre_pre = year{year_now};
    year_pre = year{year_now+1};

    %种植可能性矩阵
    constr_prop = zeros(41, 82);
    constr_prop(1:15,1:26) = 1; %约束粮食（除水稻）
    constr_prop(16,27:34) = 1;%约束水稻(不种水稻)
    constr_prop(17:34,[27:54,79:82]) = 1;%约束除了大白红以外的蔬菜
    constr_prop(35:37,55:62) = 1;%约束大白红
    constr_prop(38:41,63:78) = 1;%约束食用菌
    %%
    constr_prop(year_pre == 1) = 0;
    %%
    %优化变量
    year_plan = binvar(41, 82);
    year_true = year_plan .* constr_prop;

    constr_price=sdpvar(41,1);
    constr_yield_acre=sdpvar(41,82);
    constr_sales=sdpvar(41,1);
    
    %约束条件
    constr = [];
    
    %种植类多少
    for id_land = [1:54,63:82]
        constr = [constr, sum(year_true(:,id_land)) >= 1, sum(year_true(:,id_land)) <= 2]; %每个地块不超过两类
    end
   

    for id_land = 55:62
        constr = [constr, sum(year_true(:,id_land)) == 1]; %大白红选其中之一
    end

    for id_plant = 1:41
        for id_land = 51:54
            constr = [constr, (year_true(id_plant,id_land) + year_true(id_plant,id_land+28)) <= 1]; %避免同一年两季重复种植
        end
    end
    
    %至少三年一次豆类
    if(year_now ~= 1)
        year_3 = (year_pre_pre + year_pre + year_true);
        for id_land = 1:50
            constr = [constr, sum(year_3([1:5,17:19],id_land)) >= 1];
        end

        for id_land = 51:54
            constr = [constr, sum( year_3([1:5,17:19],id_land) + year_3([1:5,17:19],id_land + 28) ) >= 1];
        end
    end

    constr=[constr,(table2array(constr_price_new_min)<=constr_price)&(constr_price<=table2array(constr_price_new_max))];
    constr=[constr,(constr_yield_acre_min<=constr_yield_acre)&(constr_yield_acre<=constr_yield_acre_max)];
    constr=[constr,(constr_sales_new_min<=constr_sales)&(constr_sales<=constr_sales_new_max)];

    %不可能的置为0
    for id_land = 1:82
        for id_plant = 1:41
            if(constr_prop(id_plant, id_land) == 0)
                constr = [constr, year_plan(id_plant, id_land) == 0];
            end
        end
    end
    
    %重复计数
    sum_count = repmat(sum(year_true),41,1);
    %%
    %目标函数
    % obj = - (sum( min( sum( (year_plan .* constr_prop .* constr_yield_acre .* constr_area) ,2 ) , constr_sales ) .* constr_price.data_price) ...
    %      - sum(sum(year_plan .* constr_prop .* constr_area .*constr_cost_acre)));

    year_rev = sum( (year_plan .* constr_prop .* constr_yield_acre .* constr_area) ,2 );
    obj = - (sum( min( year_rev, constr_sales ) .* constr_price ) + ...
             sum( abs( year_rev - min( year_rev, constr_sales )) * 0.5 .* constr_price ) ...
             - sum(sum(year_plan .* constr_prop .* constr_area .*constr_cost_acre )));

    %优化求解
    options = sdpsettings('verbose',2, 'solver', 'gurobi');
    optimize(constr, obj, options);

    result = double(year_plan.* constr_prop);
    price_result = double(constr_price);
    yield_acre_result = double(constr_yield_acre);
    sales_result = double(constr_sales);
    
    % 创建可视化图像
    xidx = (constr_area_1{:,1})';
    yidx = (data_plant{:,2})';
    figure('Position',[100,100,1200,600])
    heatmap(xidx,yidx,result)
    colormap([1,1,1;0.2,0.2,0.2])

    year{year_now + 2} = result; %每年的0-1矩阵，从2022开始
    index_two = find(sum(result) == 2);
    result(:, index_two) = result(:, index_two) / 2;
    plan{year_now} = result .* constr_area; %要填入结果表的面积
    % objective = sum( min( sum( (result .* constr_yield_acre .* constr_area) ,2 ) , constr_sales ) .* constr_price) ...
    %      - sum(sum(result .* constr_area .*constr_cost_acre));

    year_rev_renew = sum( (result .* yield_acre_result .* constr_area) ,2 );
    objective = (sum( min( year_rev_renew, sales_result ) .* price_result ) + ...
             sum( abs( year_rev_renew - min( year_rev_renew, sales_result )) * 0.5 .* price_result ) ...
             - sum(sum( result .* constr_area .* constr_cost_acre )));

    revenue{year_now + 1} = objective; %每年的收益，从2023开始
    year_now = year_now + 1;
end
