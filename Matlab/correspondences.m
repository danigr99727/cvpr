clear all;

%Pictures changing camera position
%I1 = rgb2gray(imread('20210204_160141.jpg'));
%I2 = rgb2gray(imread('20210204_160143.jpg'));
%Pictures from fixed point
%I1 = rgb2gray(imread('20210204_160314.jpg'));
%I2 = rgb2gray(imread('20210204_160339.jpg'));
%Change scale
I1 = rgb2gray(imread('20210204_160314.jpg'));
I2 = rgb2gray(imread('20210204_160327.jpg'));

points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);
%points1 = detectSURFFeatures(I1);
%points2 = detectSURFFeatures(I2);

[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

indexPairs = matchFeatures(features1,features2);%,'MaxRatio',0.4);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage');