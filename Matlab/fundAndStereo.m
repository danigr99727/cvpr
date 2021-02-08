clear all;

I1 = rgb2gray(imread('StereoImages/left_ori/l1.jpg'));
I2 = rgb2gray(imread('StereoImages/right_ori/r1.jpg'));

%points1 = detectHarrisFeatures(I1);
%points2 = detectHarrisFeatures(I2);
%points1 = detectSURFFeatures(I1);
%points2 = detectSURFFeatures(I2);

%[features1,valid_points1] = extractFeatures(I1,points1);
%[features2,valid_points2] = extractFeatures(I2,points2);

%indexPairs = matchFeatures(features1,features2);

%matchedPoints1 = valid_points1(indexPairs(:,1),:);
%matchedPoints2 = valid_points2(indexPairs(:,2),:);

%figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');

%y = matchedPoints2.Location;
%x = matchedPoints1.Location;

%Points were obtained manually
x = load('leftStereo.mat');
x = x.leftStereo
y = load('rightStereo.mat');
y = y.rightStereo

A = []
for i=1:size(x,1)
    x1 = x(i,1);
    x2 = x(i,2);
    y1 = y(i,1);
    y2 = y(i,2);
    a = [y1*x1, y1*x2, y1, y2*x1, y2*x2, y2, x1, x2, 1];
    
    A = [A; a];
end

[~,~,V] = svd(A' * A)

h = (V(1:end,end) / V(end,end))';

F = [h(1:3); h(4:6); h(7:9)]

%F_auto = estimateFundamentalMatrix(y,x)

%[~,~,V_F] = svd(F' * F)

%e = (V_F(1:end,end) / V_F(end,end))';

epipolarLineParams = @(x, y) F * [x; y; 1];

epipolarY = @(x, ptx, pty) [-x, 0, -1] * epipolarLineParams(ptx, pty) / ([0,1,0]*epipolarLineParams(ptx, pty));
                        
epipolarLine = @(X, ptx, pty) [epipolarY(X(1),ptx,pty),epipolarY(X(2),ptx,pty)];

fig1 = figure;
a = axes;
fig2 = figure;
a2 = axes;

colours = ['y','m','c','r','g','b','w','k']

imshow(I2, 'Parent', a);
hold on;
for i=1:size(x,1)
    col = colours(rem(i,length(colours))+1);
    plot(x(i,1),x(i,2),'Marker','+','Color',col, 'MarkerSize', 10, 'LineWidth', 1, 'Parent', a);
end
hold off;

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

