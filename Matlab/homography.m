I1 = rgb2gray(imread('20210204_160141.jpg'));
I2 = rgb2gray(imread('20210204_160143.jpg'));

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
    a_x = [-x1, -y1, -1, 0, 0, 0, x2*x1, x2*y1, x2];
    a_y = [0, 0, 0, -x1, -y1, -1, y2*x1, y2*y1, y2];
    
    A = [A; a_x; a_y];
end

[~,~,V] = svd(A)

h = (V(1:end,end) / V(end,end))';

H = [h(1:3); h(4:6); h(7:9)]
