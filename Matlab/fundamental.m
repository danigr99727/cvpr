I1 = rgb2gray(imread('20210204_160339.jpg'));
I2 = rgb2gray(imread('20210204_160327.jpg'));

points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);
%points1 = detectSURFFeatures(I1);
%points2 = detectSURFFeatures(I2);

[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

indexPairs = matchFeatures(features1,features2);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');

y = matchedPoints2.Location;
x = matchedPoints1.Location;

A = []
for i=1:size(xy,1)
    x1 = x(i,1);
    x2 = x(i,2);
    y1 = y(i,1);
    y2 = y(i,2);
    a = [y1*x1, y1*x2, y1, y2*x1, y2*x2, y2, x1, x2, 1];
    
    A = [A; a_x; a_y];
end

[~,~,V] = svd(A)

h = (V(1:end,end) / V(end,end))';

F = [h(1:3); h(4:6); h(7:9)]

[~,~,V_F] = svd(F)

e = (V_F(1:end,end) / V_F(end,end))';

figure;
imshow(I1);
hold on;
% Need to check which image to do this on
% iterate through all the points:   for pt=y;
plot(e(1),e(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold off;
