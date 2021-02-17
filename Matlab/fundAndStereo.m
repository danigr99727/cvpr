clear all
close all

I1 = rgb2gray(imread('StereoImages/right_ori/r5.jpg'));
I2 = rgb2gray(imread('StereoImages/left_ori/l5.jpg'));

%I1 = rgb2gray(imread('20210204_160141.jpg'));
%I2 = rgb2gray(imread('20210204_160143.jpg'));

<<<<<<< HEAD
I2 = rgb2gray(col2);
I1 = rgb2gray(col1);
=======
I1 = (I1);
I2 = (I2);
>>>>>>> 276ca5cacc110de5ad1c48812921ff47be95a09d

%Points were obtained manually
reflectionCentre = ([ones(14,1) * 4033, ones(14,1) * 3025]);
y = load('l5.mat');
y = y.l5;
%x = reflectionCentre - x;
x = load('r5.mat');
x = x.r5;
%y = reflectionCentre - y;

%% alternative images
% I1 = rgb2gray(imread('20210204_160143.jpg'));
% I2 = rgb2gray(imread('20210204_160141.jpg'));
% 
% x = load('savePointsA.mat');
% x = x.fixedPoints
% y = load('savePointsB.mat');
% y = y.movingPoints



%F = getFundamental(x, y);

F = estimateFundamentalMatrix(x,y);

%epipolarLineParams = @(x, y) F * [x; y; 1];
%epipolarY = @(x, ptx, pty) [-x, 0, -1] * epipolarLineParams(ptx, pty) / ([0,1,0]*epipolarLineParams(ptx, pty));
%epipolarLine = @(X, ptx, pty) [epipolarY(X(1),ptx,pty),epipolarY(X(2),ptx,pty)];

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
    
    mat = epipolarLine(F, x(i,:));
    a = mat(1);
    b = mat(2);
    c = mat(3);
    epLineX2Y = @(x) (-a*x-c)/b;
    
    X = [0 4032];
    plot(X,epLineX2Y(X),'Color',col,'Parent',a2);
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
%I1 = imresize(rgb2gray(imread('forDisparity/20210215_115626.jpg')), [3024/2, 4032/2]);

%I2 = imresize(rgb2gray(imread('forDisparity/20210215_115643.jpg')), [3024/2, 4032/2]);

points1 = detectORBFeatures(I1);
points2 = detectORBFeatures(I2);

[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

%indexPairs = matchFeatures(features1,features2);%,'MaxRatio',0.4);

indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD','MatchThreshold', 5);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

%matchedPoints1 = x;
%matchedPoints2 = y;

%matchedPoints1 = cat(1, matchedPoints1.Location, x); 
%matchedPoints2 = cat(1, matchedPoints2.Location, y); 

figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');

[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

if status ~= 0 || isEpipoleInImage(fMatrix, size(I1)) ...
  || isEpipoleInImage(fMatrix', size(I2))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);


figure; showMatchedFeatures(I1, I2,matchedPoints1,matchedPoints2,'montage');
[t1, t2] = estimateUncalibratedRectification(F, inlierPoints1, inlierPoints2, size(I2));

tform1 = projective2d(t1);
tform2 = projective2d(t2);

[J1, J2] = rectifyStereoImages(I1, I2, tform1, tform2);

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

%% epipolar matching...

points1 = detectORBFeatures(J1);
points2 = detectORBFeatures(J2);

[features1,valid_points1] = extractFeatures(J1,points1);
[features2,valid_points2] = extractFeatures(J2,points2);

indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD','MatchThreshold', 5);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);


[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

matchedPoints1 = matchedPoints1.Location;
matchedPoints2 = matchedPoints2.Location;

fig11 = figure;
aa = axes;

colours = ['y','m','c','r','g','b','w','k'];

imshow(J1, 'Parent', aa);
hold on;
for i=1:size(matchedPoints1,1)
    col = colours(rem(i,length(colours))+1);
    plot(matchedPoints1(i,1),matchedPoints1(i,2),'Marker','+','Color',col, 'MarkerSize', 10, 'LineWidth', 1, 'Parent', aa);
end
hold off;


fig12 = figure;
aa2 = axes;

imshow(J2, 'Parent', aa2);
hold on;
for i=1:size(matchedPoints2,1)
    col = colours(rem(i,length(colours))+1);
    plot(matchedPoints2(i,1),matchedPoints2(i,2),'Marker','+','Color',col,'MarkerSize', 10, 'LineWidth', 1, 'Parent', aa2);
    
    mat = epipolarLine(F, matchedPoints1(i,:));
    a = mat(1);
    b = mat(2);
    c = mat(3);
    epLineX2Y = @(matchedPoints1) (-a*matchedPoints1-c)/b;
    
    X = [0 4032];
    plot(X,epLineX2Y(X),'Color',col,'Parent',aa2);
end
hold off;


%% reconstruct 3D

%points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
%points3D = points3D ./ 1000;
%ptCloud = pointCloud(points3D);

% Create a streaming point cloud viewer
%player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
%    'VerticalAxisDir', 'down');

% Visualize the point cloud
%view(player3D, ptCloud);