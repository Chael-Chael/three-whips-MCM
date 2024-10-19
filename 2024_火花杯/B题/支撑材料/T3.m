mod_Z=abs(CSI5);
phase_Z=angle(CSI5);
matrixA=(7:127);matrixB=(131:250);
matrix=[matrixA,matrixB];
matrix1=matrix-ones([1,241]);
removeCols = [1:6, 128:130,251:256];
% 保留的列的索引
keepCols = setdiff(1:size(phase_Z, 2), removeCols);
% 删除指定的列
newphase_Z = phase_Z(:, keepCols);
% 保留的列的索引
keepCols = setdiff(1:size(phase_Z, 2), removeCols);
% 删除指定的列
newmod_Z = mod_Z(:, keepCols);
CSI5_new=CSI5(:,keepCols);

%画幅度图
for i = 1:24
figure(1);
plot(matrix,newmod_Z(i,:),'color', c(i,:),'Linewidth',1);
hold on;
end
xlabel('子载波序号');
ylabel('幅度');
title('CSI5的24个时刻幅度图');

% 初始化解卷绕后的CSI数据矩阵
unwrappedCSI = zeros(size(newphase_Z));

% 先进行时间域上的解卷绕
for f = 1:241
    for t = 2:24
        % 计算相邻时刻的相位差
        phase_diff = newphase_Z(t, f) - newphase_Z(t-1, f);
        
        % 如果相位差超过pi，进行解卷绕
        if abs(phase_diff) > pi
            if phase_diff > 0
                newphase_Z(t, f) = newphase_Z(t, f) - 2 * pi;
            else
                newphase_Z(t, f) = newphase_Z(t, f) + 2 * pi;
            end
        end
    end
end

% 然后进行子载波域内的解卷绕
for t = 1:24
    for f = 2:241
        phase_diff = newphase_Z(t, f) -newphase_Z(t, f-1);
        
        % 如果相位差超过pi，进行解卷绕
        if phase_diff > pi
            while(abs(phase_diff)>pi)
                newphase_Z(t, f) = newphase_Z(t, f) - 2 * pi;
                phase_diff = newphase_Z(t, f) -newphase_Z(t, f-1);
            end
        end
        if phase_diff<-pi
           while(abs(phase_diff)>pi) 
                newphase_Z(t, f) = newphase_Z(t, f) + 2 * pi;
                phase_diff = newphase_Z(t, f) -newphase_Z(t, f-1);
           end
        end
    end
end

% 保存解卷绕后的数据
unwrappedCSI = newphase_Z;

c=cool(24);
for i = 1:24
figure(4);
plot(matrix,newphase_Z(i,:),'color', c(i,:),'DisplayName',strcat('第',num2str(i),'条天线'),'Linewidth',1);
hold on;
end

newphase2=zeros(23,241);
for row = 2:size(newphase_Z, 1) % 从第二行开始，因为第一行没有前一行可以相减
    % 将当前行与前一行做差，并将结果保存到B的对应行
    newphase2(row-1, :) = smoothed_y1(row, :) -smoothed_y1(row - 1, :);
end

%利用平均值代替相差的间隔PDD较大的异常值
AveDelta = zeros(1, 241);  
for col = 1:241  
    % 获取当前列  
    current_col = newphase2(:, col);  
    % 找到符合条件的元素  
    valid_elements = current_col(abs(current_col) < 0.2);  
    % 计算均值  
    if ~isempty(valid_elements)  
        AveDelta(col) = mean(abs(valid_elements));  
    else  
        AveDelta(col) = NaN; % 如果没有符合条件的元素，可以选择 NaN  
    end  
end  

for j=1:241
    for i=1:23
        if(abs(newphase2(i,j))>=0.2)
            if(newphase2(i,j)>0)
                newphase2(i,j)=AveDelta(1,j);
            end
             if(newphase2(i,j)<0)
                newphase2(i,j)=-AveDelta(1,j);
             end
        end
    end
end

newphase3=zeros(24,241);
newphase3(1,:)=smoothed_y1(1,:);
for row = 2:size(unwrapped_phase, 1)
    newphase3(row, :) = newphase3(row-1, :) + newphase2(row - 1, :);
end

c=cool(24);
for i = 1:24
figure(4);
plot(matrix,newphase3(i,:),'color', c(i,:),'DisplayName',strcat('第',num2str(i),'条天线'),'Linewidth',1);
hold on;
end

%平滑处理滤波部分噪声
smoothed_y1=unwrapped_phase; 
for i=1:24
smoothed_y1(i,126:168) = average_filter(unwrapped_phase(i,126:168));
smoothed_y1(i,64:95) = average_filter(unwrapped_phase(i,64:95));
smoothed_y1(i,169:190) = average_filter(unwrapped_phase(i,169:190));
end
for i=1:24
figure(3);
plot(matrix,smoothed_y1(i,:),'color', c(i,:),'Linewidth',1);
hold on;
end


%考虑进行线性消除
x1=(-120:120);
y=newphase_Z;
y_new=zeros(24,241);
b1=zeros(24,1);
for i=1:24
% deltaPhi=newphase_Z(i,241)-newphase_Z(i,1);
b1(i,1)=sum(y(i,:))/241;
 p=polyfit(x1,y(i,:),1);
 % y_new(i,:)=y(i,:)-(-p(1))*x1(i)+b1(i,1);
for j=1:241
% y_new(i,j)=y(i,j)-(deltaPhi/240)*x1(j)-b1(i,1);
y_new(i,j)=y(i,j)-(p(1))*x1(j)-b1(i,1);
end
end
for i=1:24
newphase_Z(i,:) = y_new(i,:);
end

%做出线性消除前后的图对比
c=cool(24);
for i=1:24
figure(6);
plot(x1,newphase_Z(i,:),'color', c(i,:),'Linewidth',1);
plot(x1,unwrappedCSI(i,:),'b-','Linewidth',1);
hold on;
end
plot(x1,unwrappedCSI-newphase_Z,'b-','Linewidth',1);


% %IQ不平衡非线性消除
% c=zeros(24,241);
% r=zeros(24,241);a=zeros(24,241);CSI4_new1=zeros(24,241);
% CIS4_new=newmod_Z.*exp(smoothed_y1*1i);
% c=CSI4_new.*CSI4_new;
% r=CSI4_new.*conj(CSI4_new);
% a=-c./(r+sqrt(r.*r-c.*conj(c)));
% CSI4_new1=CSI4_new+a.*conj(CSI4_new);
% newphase=angle(CSI4_new1);
% plot(matrix(1:241),newphase(1,1:241),'r-');

%平滑处理
smoothed_y=zeros(24,241);
for i=8:13
smoothed_y(i,:) = average_filter(newmod_Z(i,:));
figure(2);
plot(matrix,smoothed_y(i,:),'b-','LineWidth',1);
hold on;
end
xlabel('子载波序号');
ylabel('幅度');
title('平滑处理后的CSI5的24个时刻幅度图');

%求解P_music的值
new_CSI5_2=newmod_Z.*exp(newphase_Z*1i);
r=zeros(241,241);
for i=1:24
  u=zeros(241,1);
  u=new_CSI5_2(i,:)';
  for j=1:120
    temp=u(j,1);
    u(241-j+1,1)=temp;
    u(j,1)=u(241-j+1);
  end
  r=r+u*u';
end
r=r./24;
[Q, E] = eig(r);
[eigenvalues, idx] = sort(diag(E), 'descend');
plot((1:241),eigenvalues','r*-');
Q1=zeros(240,241);
Q1=Q(:,1:240)';
sk=zeros(241,1);
%tau_scan = linspace(-3e-7,3e-7,200);

tau_scan = linspace(0,2e-7,100);tau_scan1=tau_scan';
deltaf=61440000/256;
P_music=zeros(100,1);
for j=1:100
    sk(121,1)=exp(-2*pi*1i*tau_scan(1,j)*5.1*power(10,9));
 for k=1:120
    sk(k,1)=sk(121,1)*exp(2*pi*1i*tau_scan(1,j)*deltaf*(121-k));
    sk(121+k)=sk(121,1)*exp(-2*pi*1i*tau_scan(1,j)*deltaf*(k));
 end
 P_music(j,1)=1/norm(Q1*sk,2);
 plot(tau_scan(j),P_music(j,1),'r-');
 hold on
end
plot(tau_scan,P_music,'r-');
xlabel('时间延迟');
ylabel('MUSIC谱功率(dB)');
title('MUSIC谱');
