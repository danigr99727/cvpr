clear all;

I1 = rgb2gray(imread('20210204_160141.jpg'));
I2 = rgb2gray(imread('20210204_160143.jpg'));

%Points were obtained manually
x = load('savePointsA.mat');
x = x.fixedPoints
y = load('savePointsB.mat');
y = y.movingPoints

%A = []
%for i=1:size(x,1)
%    x1 = x(i,1);
%    x2 = x(i,2);
%    y1 = y(i,1);
%    y2 = y(i,2);
%    a = [y1*x1, y1*x2, y1, y2*x1, y2*x2, y2, x1, x2, 1];
%    
%    A = [A; a];
%end

%[~,~,V] = svd(A' * A)

%h = (V(1:end,end) / V(end,end))';

%F = [h(1:3); h(4:6); h(7:9)]

F = estimateFundamentalMatrix(x,y)

%[~,~,V_F] = svd(F' * F)

%e = (V_F(1:end,end) / V_F(end,end))';

epipolarLineParams = @(x, y) F * [x; y; 1];

epipolarY = @(x, ptx, pty) [-x, 0, -1] * epipolarLineParams(ptx, pty) / ([0,1,0]*epipolarLineParams(ptx, pty));
                        
epipolarLine = @(X, ptx, pty) [epipolarY(X(1),ptx,pty),epipolarY(X(2),ptx,pty)];

fig1 = figure;
a = axes;

colours = ['y','m','c','r','g','b','w','k']

imshow(I2, 'Parent', a);
hold on;
for i=1:size(x,1)
    col = colours(rem(i,length(colours))+1);
    plot(x(i,1),x(i,2),'Marker','+','Color',col, 'MarkerSize', 10, 'LineWidth', 1, 'Parent', a);
end
hold off;


fig2 = figure;
a2 = axes;

imshow(I1, 'Parent', a2);
hold on;
for i=1:size(x,1)
    col = colours(rem(i,length(colours))+1);
    plot(y(i,1),y(i,2),'Marker','+','Color',col,'MarkerSize', 10, 'LineWidth', 1, 'Parent', a2);
    X = [0 4032];
    Y = epipolarLine(X, x(i,1), x(i,2));
    plot(X,Y,'Color',col,'Parent',a2);
end
hold off;

