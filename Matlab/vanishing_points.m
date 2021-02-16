clear all;

I1 = rgb2gray(imread('20210204_160041.jpg'));
I2 = rgb2gray(imread('20210204_160052.jpg'));

%Points were obtained manually
x = load('vanA.mat');
x = x.vanA;
y = load('vanB.mat');
y = y.vanB;

fig1 = figure;
a = axes;
fig2 = figure;
a2 = axes;

colours = ['y','m']
first = [1,3,1,2];
second = [2,4,3,4];

padX = 15000;
padY = 15000;
extendedI1 = padarray(I1, [padX padY]);
imshow(extendedI1, 'Parent', a);
lines = []
hold on;
for i=1:4
plot(padX+x(i,1),padY+x(i,2),'Marker','+','Color','c', 'MarkerSize', 10, 'LineWidth', 1, 'Parent', a);
end
for i=1:4
X = [-padX, 4032+padX];
p = polyfit([x(first(i),1),x(second(i),1)], [x(first(i),2),x(second(i),2)], 1);
lines = [lines; p]
Y = polyval(p,X);
plot(padX+X,padY+Y,'Color',colours(floor((i-1)/2)+1),'Parent',a);
end

v1x = (lines(2,2)-lines(1,2))/(lines(1,1)-lines(2,1));
v1y = lines(1,1)*v1x + lines(1,2);
v2x = (lines(4,2)-lines(3,2))/(lines(3,1)-lines(4,1));
v2y = lines(3,1)*v2x + lines(3,2);
plot(v1x+padX,padY+v1y,'Marker','+','Color','w', 'MarkerSize', 30, 'LineWidth', 1, 'Parent', a);
plot(v2x+padX,padY+v2y,'Marker','+','Color','w', 'MarkerSize', 30, 'LineWidth', 1, 'Parent', a);

h_par = [(v2y-v1y)/(v2x-v1x); v2y - (v2y-v1y)/(v2x-v1x)*v2x];
Y = polyval(h_par,X);
plot(padX+X+1,padY+Y,'Color','w', 'LineWidth', 2, 'Parent', a);
hold off;


padX = 5000;
padY = 5000;
extendedI2 = padarray(I2, [padX padY]);
imshow(extendedI2, 'Parent', a2);
lines = []
hold on;
for i=1:4
plot(padX+y(i,1),padY+y(i,2),'Marker','+','Color','c', 'MarkerSize', 10, 'LineWidth', 1, 'Parent', a2);
end
for i=1:4
    X = [-5000,9032];
    p = polyfit([y(first(i),1),y(second(i),1)], [y(first(i),2),y(second(i),2)], 1);
    lines = [lines; p]
    Y = polyval(p,X);
    plot(padX+X,padY+Y,'Color',colours(floor((i-1)/2)+1),'Parent',a2);
end

v1x = (lines(2,2)-lines(1,2))/(lines(1,1)-lines(2,1));
v1y = lines(1,1)*v1x + lines(1,2);
v2x = (lines(4,2)-lines(3,2))/(lines(3,1)-lines(4,1));
v2y = lines(3,1)*v2x + lines(3,2);
plot(v1x+padX,padY+v1y,'Marker','+','Color','w', 'MarkerSize', 30, 'LineWidth', 1, 'Parent', a2);
plot(v2x+padX,padY+v2y,'Marker','+','Color','w', 'MarkerSize', 30, 'LineWidth', 1, 'Parent', a2);

h_par = [(v2y-v1y)/(v2x-v1x); v2y - (v2y-v1y)/(v2x-v1x)*v2x];
Y = polyval(h_par,X);
plot(padX+X,padY+Y,'Color','w', 'LineWidth', 2, 'Parent', a2);
hold off;


