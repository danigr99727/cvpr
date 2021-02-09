function F = getFundamental(x, y)
    A = getA(x,y);
    [~,~,V] = svd(A' * A)
    h = (V(1:end,end) / V(end,end))';
    F = [h(1:3); h(4:6); h(7:9)]
end