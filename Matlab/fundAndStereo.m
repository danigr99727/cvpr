clear all;

col2 = imread('StereoImages/left_ori/l5.jpg');
col1 = imread('StereoImages/right_ori/r5.jpg');

I2 = rgb2gray(col2);
I1 = rgb2gray(col1);

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


%% rectify 

stereoParams = load('stereoParams.mat');
stereoParams = stereoParams.stereoParams;

%tmp = getframe(fig1);
%[i1, Map] = frame2im(tmp);
%tmp = getframe(fig2);
%[i2, Map] = frame2im(tmp);

[J1, J2] = rectifyStereoImages(I2, I1, stereoParams,'OutputView','Full');

fig3 = figure;
a3 = axes;
imshow(J1, 'Parent', a3);

fig45 = figure;
a4 = axes;
imshow(J2, 'Parent', a4);

%% compute disparity
    
disparityMap = disparitySGM(J1, J2);
figure;
imshow(disparityMap, [0, 64]);
title('Disparity Map');
colormap jet
colorbar

%% reconstruct 3D

points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
ptCloud = pointCloud(points3D);

% Create a streaming point cloud viewer
player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D, ptCloud);