I1 = rgb2gray(imread('20210204_160141.jpg'));
I2 = rgb2gray(imread('20210204_160143.jpg'));

%points1 = detectHarrisFeatures(I1);
%points2 = detectHarrisFeatures(I2);
%points1 = detectSURFFeatures(I1);
%points2 = detectSURFFeatures(I2);

%[features1,valid_points1] = extractFeatures(I1,points1);
%[features2,valid_points2] = extractFeatures(I2,points2);

%indexPairs = matchFeatures(features1,features2);

%matchedPoints1 = valid_points1(indexPairs(:,1),:);
%matchedPoints2 = valid_points2(indexPairs(:,2),:);

%Points were obtained manually

%figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');

%y = matchedPoints2.Location;
%x = matchedPoints1.Location;

x = load('savePointsA.mat');
x = x.fixedPoints
y = load('savePointsB.mat');
y = y.movingPoints

A = []
for i=1:size(x,1)
    x1 = x(i,1);
    x2 = x(i,2);
    y1 = y(i,1);
    y2 = y(i,2);
    a_x = [-x1, -y1, -1, 0, 0, 0, x2*x1, x2*y1, x2];
    a_y = [0, 0, 0, -x1, -y1, -1, y2*x1, y2*y1, y2];
    
    A = [A; a_x; a_y];
end

[~,~,V] = svd(A)

h = (V(1:end,end) / V(end,end))';

H = [h(1:3); h(4:6); h(7:9)]

transformed_x = H * [x, ones(size(x,1),1)]';
transformed_x = transformed_x(1:2,:)';

figure(1);
imshow(I2);
hold on;
figure(1);
plot(x(:,1),x(:,2),'y+', 'MarkerSize', 10, 'LineWidth', 1);
hold off;

figure(2);
imshow(I1);
hold on;
figure(2);
plot(y(:,1),y(:,2),'y+', 'MarkerSize', 10, 'LineWidth', 1);
hold on;
figure(2);
plot(transformed_x(:,1),transformed_x(:,2),'r+', 'MarkerSize', 10, 'LineWidth', 1);
holf off;
