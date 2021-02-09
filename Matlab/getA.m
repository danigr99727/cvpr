function A = getA(x,y)

    A = []
    for i=1:size(x,1)
        x1 = x(i,1);
        x2 = x(i,2);
        y1 = y(i,1);
        y2 = y(i,2);
        a = [y1*x1, y1*x2, y1, y2*x1, y2*x2, y2, x1, x2, 1];

        A = [A; a];
    end

end
