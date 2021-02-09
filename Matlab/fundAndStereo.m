clear all;

I2 = rgb2gray(imread('StereoImages/left_ori/l5.jpg'));
I1 = rgb2gray(imread('StereoImages/right_ori/r5.jpg'));

%Points were obtained manually
reflectionCentre = [ones(14,1) * 4033, ones(14,1) * 3025];
x = load('r5.mat');
x = x.r5
%x = reflectionCentre - x;
y = load('l5.mat');
y = y.l5
%y = reflectionCentre - y;


%F = getFundamental(x, y);

F = estimateFundamentalMatrix(x,y)

epipolarLineParams = @(x, y) F * [x; y; 1];

epipolarY = @(x, ptx, pty) [-x, 0, -1] * epipolarLineParams(ptx, pty) / ([0,1,0]*epipolarLineParams(ptx, pty));
                        
epipolarLine = @(X, ptx, pty) [epipolarY(X(1),ptx,pty),epipolarY(X(2),ptx,pty)];

fig1 = figure;
a = axes;

colours = ['y','m','c','r','g','b','w','k']

imshow(I1, 'Parent', a);
hold on;
for i=1:size(x,1)
    col = colours(rem(i,length(colours))+1);
    plot(x(i,1),x(i,2),'Marker','+','Color',col, 'MarkerSize', 10, 'LineWidth', 1, 'Parent', a);
end
hold off;


fig2 = figure;
a2 = axes;

imshow(I2, 'Parent', a2);
hold on;
for i=1:size(x,1)
    col = colours(rem(i,length(colours))+1);
    plot(y(i,1),y(i,2),'Marker','+','Color',col,'MarkerSize', 10, 'LineWidth', 1, 'Parent', a2);
    
    X = [0 4032];
    Y = epipolarLine(X, x(i,1), x(i,2));
    plot(X,Y,'Color',col,'Parent',a2);
end
hold off;

