clear all
close all

I1 = rgb2gray(imread('StereoImages/left_ori/l5.jpg'));
I2 = rgb2gray(imread('StereoImages/right_ori/r5.jpg'));

I1 = (I1);
I2 = (I2);

%Points were obtained manually
reflectionCentre = ([ones(14,1) * 4033, ones(14,1) * 3025]);
x = load('l5.mat');
x = x.l5;
%x = reflectionCentre - x;
y = load('r5.mat');
y = y.r5;
%y = reflectionCentre - y;


%F = getFundamental(x, y);

F = estimateFundamentalMatrix(x,y);

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

%stereoParams = load('stereoParams.mat');
%stereoParams = stereoParams.stereoParams;

%tmp = getframe(fig1);
%[i1, Map] = frame2im(tmp);
%tmp = getframe(fig2);
%[i2, Map] = frame2im(tmp);

%[J1, J2] = rectifyStereoImages(I1, I2, stereoParams,'OutputView','Full');

%detecting orb features

points1 = detectORBFeatures(I1);
points2 = detectORBFeatures(I2);

[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

indexPairs = matchFeatures(features1,features2);%,'MaxRatio',0.4);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

matchedPoints1 = cat(1, matchedPoints1.Location, x);
matchedPoints2 = cat(1, matchedPoints2.Location, y);

figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');


showMatchedFeatures(I1, I2,matchedPoints1,matchedPoints2,'montage');
[T1, T2] = estimateUncalibratedRectification(F, matchedPoints1, matchedPoints2, size(I2));
[J1, J2] = rectifyStereoImages(I1, I2, T1, T2);
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

%points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
%ptCloud = pointCloud(points3D);

% Create a streaming point cloud viewer
%player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
%    'VerticalAxisDir', 'down');

% Visualize the point cloud
%view(player3D, ptCloud);