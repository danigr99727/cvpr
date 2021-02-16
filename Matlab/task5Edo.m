clear all;

I1 = imread('StereoImages/left_ori/l5.jpg');
I2 = imread('StereoImages/right_ori/r5.jpg');

% Convert to grayscale.
I1gray = rgb2gray(I1);
I2gray = rgb2gray(I2);

%Points were obtained manually
reflectionCentre = [ones(14,1) * 4033, ones(14,1) * 3025];
x = load('l5.mat');
x = x.l5
%x = reflectionCentre - x;
y = load('r5.mat');
y = y.r5
%y = reflectionCentre - y;

%% display initial images and points

figure;
in1 = axes;
imshow(I1, 'Parent', in1);
hold on;
for i=1:size(x,1)
    plot(x(i,1), x(i,2), 'Marker','+','Color','r','MarkerSize', 10, 'LineWidth', 1, 'Parent', in1);
end
hold off;

figure;
in2 = axes;
imshow(I2, 'Parent', in2);
hold on;
for i=1:size(y,1)
    plot(y(i,1), y(i,2), 'Marker','+','Color','r','MarkerSize', 10, 'LineWidth', 1, 'Parent', in2);
end
hold off;

%% estimate fundamental matrix

F = estimateFundamentalMatrix(x,y);

%% rectify

[t1, t2] = estimateUncalibratedRectification(F, ...
  x, y, size(I2));
tform1 = projective2d(t1);
tform2 = projective2d(t2);

[I1Rect, I2Rect] = rectifyStereoImages(I1, I2, tform1, tform2);

offset = 950;
offY = 50;

figure;
a = axes;
imshow(I1Rect, 'Parent', a);
hold on;
for i=1:size(x,1)
    [X,Y] = transformPointsForward(tform1, x(i,1), x(i,2));
    plot(X-offset, Y-offY, 'Marker','+','Color','r','MarkerSize', 10, 'LineWidth', 1, 'Parent', a);
end
hold off;



epipolarLineParams = @(x, y) F * [x; y; 1];
epipolarY = @(x, ptx, pty) [-x, 0, -1] * epipolarLineParams(ptx, pty) / ([0,1,0]*epipolarLineParams(ptx, pty));                       
epipolarLine = @(X, ptx, pty) [epipolarY(X(1),ptx,pty),epipolarY(X(2),ptx,pty)];

figure;
a2 = axes;
imshow(I2Rect, 'Parent', a2);
hold on;
for i=1:size(y,1)
    [X,Y] = transformPointsForward(tform2, y(i,1), y(i,2));
    plot(X-offset, Y-offY, 'Marker','+','Color','r','MarkerSize', 10, 'LineWidth', 1, 'Parent', a2);
    
    X = [0 4032];
    Y = epipolarLine(X, x(i,1), x(i,2));
    [X1,Y1] = transformPointsForward(tform2, X(1), Y(1));
    [X2,Y2] = transformPointsForward(tform2, X(2), Y(2));
    plot([X1 X2]-offset,[Y1 Y2]-offY,'Color','w','Parent',a2);
end
hold off;