clc, clear
% 定义节点数
% numNodes = 70;
%
% % 生成随机的边
% numEdges = 140;
% s = zeros(1, numEdges);
% t = zeros(1, numEdges);
%
% while true
%
%     for i = 1:numEdges
%
%         while true
%             s(i) = randi(numNodes);
%             t(i) = randi(numNodes);
%
%             if s(i) ~= t(i) && ...
%                     ~any((s(1:i - 1) == s(i) & t(1:i - 1) == t(i)) | ...
%                     (s(1:i - 1) == t(i) & ...
%                     t(1:i - 1) == s(i))) % 确保起始节点和目标节点不同，避免自环，且边不重复
%                 break;
%             end
%
%         end
%
%     end
%
%     % 创建图
%     G = graph(s, t);
%
%     % 检查是否有孤立的节点
%     if all(degree(G) > 0)
%         break; % 如果所有的节点都不是孤立的，那么退出循环
%     end
%
% end
%
% % 绘制图
% plot(G, 'Layout', 'force');
%%
%输入已知数据
NDof = 2; %每个结点的自由度数
iopt = 1; %平面应力问题
E = 2.06e5; %材料弹性模量
v = 0.3; %材料泊松比
t = 10; %板厚度

num_x = 11; % x坐标划分为11个结点
num_y = 11; % y坐标划分为11个结点

% 定义结点坐标
x = linspace(0, 300, num_x); % x坐标，从0到300，共11*n个点
y = linspace(0, 200, num_y); % y坐标，从0到200，共11*n个点

% 生成网格
[X, Y] = meshgrid(x, y);

% 将2D网格坐标转换为列向量
X = X(:);
Y = Y(:);

% 使用delaunay函数生成三角形网格
tri = delaunay(X, Y);

% 绘制三角形网格
triplot(tri, X, Y);

% 更新Coords和Elems数组
Coords = [X Y];
Elems = tri;
nrdof = [1 1 0; %结点自由度约束
         1 2 0;
         num_y 1 0;
         num_y 2 0;
         num_y * (num_x - 1) + 1 2 0];
% 更新结点总数和单元总数
NNodes = size(Coords, 1); %结点总数
NElems = size(Elems, 1); %单元总数
dof = gendof(Elems, NDof); %生成单元自由度数据
rdof = genbc(nrdof, NDof); %生成自由度约束向量
%% 图划分
% 1）创建邻接矩阵：首先，需要创建一个邻接矩阵来表示元素之间的接口
% 可以通过检查每个元素的节点来实现这一点：
% 如果两个元素共享一个或多个节点，那么它们就有一个接口。
% 初始化邻接矩阵
adjacency_matrix = zeros(NElems, NElems);
% 填充邻接矩阵
for i = 1:NElems

    for j = 1:NElems
        % 如果两个元素共享一个或多个节点，那么它们就有一个接口
        if i ~= j && any(ismember(Elems(i, :), Elems(j, :)))
            adjacency_matrix(i, j) = 1;
        end

    end

end

G = graph(adjacency_matrix);
%% 随机图生成完毕，接下来划分子图
%谱聚类（Spectral Clustering）
% 计算图的拉普拉斯矩阵
D = diag(degree(G));
A = adjacency(G);
L = D - A;

% 计算拉普拉斯矩阵的前k个最小的特征向量
numSubgraphs = 4;
[V, ~] = eigs(L, numSubgraphs, 'smallestreal');

% 对特征向量进行k-means聚类
idx = kmeans(V, numSubgraphs);

% 绘制划分后的图
figure;
plot(G, 'MarkerSize', 10, 'NodeCData', idx, 'Layout', 'force');

%% 聚类结果投影到原来的板子上
colors = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];

% 绘制Delaunay三角剖分
triplot(tri, X, Y);

hold on;

% 对每个聚类进行迭代
for i = unique(idx)'
    % 获取当前聚类的点
    triangles = tri(idx == i, :);

    % 绘制当前聚类的点
    triplot(triangles, X, Y, 'Color', colors(mod(i, length(colors)) + 1));
    % 计算每个三角单元的中心
    centers = (X(tri(:, 1)) + X(tri(:, 2)) + X(tri(:, 3))) / 3;
    centersY = (Y(tri(:, 1)) + Y(tri(:, 2)) + Y(tri(:, 3))) / 3;

    % 在每个三角单元的中心添加文本
    for i = 1:size(tri, 1)
        text(centers(i), centersY(i), num2str(i), 'FontSize', 8);
    end

end

hold off;
%% Functions

% 位移约束定义的自动转换函数
function [bc] = genbc (Nbc, NDof)
    bc(:, 1) = NDof * (Nbc(:, 1) - 1) + Nbc(:, 2); %由结点总体号及自由度号计算总体自由度编号
    bc(:, 2) = Nbc(:, 3); %自由度约束值
    size(bc) % 5*2
end

% 单元总体结点连接关系表生成单元总体自由度向量
function [Dof] = gendof(Elems, NDof)
    [NElems, NENodes] = size(Elems); % NElems单元总数，NENodes单个单元总体结点总数
    Dof = zeros(NElems, NENodes * NDof);

    for i = 1:NElems

        for j = 1:NENodes
            Dof(i, NDof * j - [NDof - 1:-1:0]) = NDof * Elems(i, j) - [NDof - 1:-1:0];
        end

    end

end
