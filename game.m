clc, clear
% 定义全局变量
global gameOver width height x y fruitX fruitY score tailX tailY nTail dir

% 初始化游戏
Setup();

% 游戏主循环
while ~gameOver
    Draw();
    Input();
    Algorithm();
    pause(0.05); % 暂停50毫秒
end

function Setup()
    global gameOver width height depth x y z fruitX fruitY fruitZ score tailX tailY tailZ nTail dir
    gameOver = false;
    dir = 0;
    width = 20;
    height = 20;
    depth = 20;
    x = width / 2;
    y = height / 2;
    z = depth / 2;
    fruitX = randi([1, width]);
    fruitY = randi([1, height]);
    fruitZ = randi([1, depth]);
    score = 0;
    tailX = zeros(1, 100);
    tailY = zeros(1, 100);
    tailZ = zeros(1, 100);
    nTail = 0;
end

function Draw()
    global width height depth x y z fruitX fruitY fruitZ tailX tailY tailZ nTail score
    persistent angle % 定义一个持久性变量

    if isempty(angle)
        angle = 0; % 如果angle为空，初始化为0
    end

    clf;
    hold on;
    axis([0 width + 1 0 height + 1 0 depth + 1]);
    grid on;
    scatter3(x, y, z, 'filled'); % 绘制蛇头
    scatter3(tailX(1:nTail), tailY(1:nTail), tailZ(1:nTail), 'filled'); % 绘制蛇身
    scatter3(fruitX, fruitY, fruitZ, 'filled', 'r'); % 绘制食物
    title(['Score: ', num2str(score)]);
    view(angle, 45); % 使用angle作为方位角
    angle = mod(angle + 1, 360); % 更新angle，使其在0到359之间循环
    hold off;
end

function Input()
    global dir gameOver

    if ~isempty(get(gcf, 'CurrentCharacter'))
        ch = get(gcf, 'CurrentCharacter');

        switch ch
            case '4'
                dir = 2; % 左
            case '6'
                dir = 1; % 右
            case '8'
                dir = 4; % 上
            case '2'
                dir = 3; % 下
            case 'w'
                dir = 5; % 前（增加z）
            case 's'
                dir = 6; % 后（减少z）
            case 'x'
                gameOver = true;
        end

    end

end

function Algorithm()
    global x y z dir width height depth tailX tailY tailZ nTail fruitX fruitY fruitZ score
    prevX = tailX(1);
    prevY = tailY(1);
    prevZ = tailZ(1);
    tailX(1) = x;
    tailY(1) = y;
    tailZ(1) = z;

    for i = 2:nTail
        prev2X = tailX(i);
        prev2Y = tailY(i);
        prev2Z = tailZ(i);
        tailX(i) = prevX;
        tailY(i) = prevY;
        tailZ(i) = prevZ;
        prevX = prev2X;
        prevY = prev2Y;
        prevZ = prev2Z;
    end

    switch dir
        case 1
            x = x + 1;
        case 2
            x = x - 1;
        case 3
            y = y + 1;
        case 4
            y = y - 1;
        case 5
            z = z + 1; % 增加z
        case 6
            z = z - 1; % 减少z
    end

    if x > width
        x = 1;
    elseif x < 1
        x = width;
    end

    if y > height
        y = 1;
    elseif y < 1
        y = height;
    end

    if z > depth
        z = 1;
    elseif z < 1
        z = depth;
    end

    if any(tailX(1:nTail) == x & tailY(1:nTail) == y & tailZ(1:nTail) == z)
        gameOver = true;
    end

    if x == fruitX && y == fruitY && z == fruitZ
        score = score + 10;
        fruitX = randi([1, width]);
        fruitY = randi([1, height]);
        fruitZ = randi([1, depth]);
        nTail = nTail + 1;
    end

end
