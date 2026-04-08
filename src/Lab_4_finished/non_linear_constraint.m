function [c, ceq] = non_linear_constraint(x, mx, N)
    alpha = 0.2;
    beta = 20;
    lambda_t = 2*pi/3;
    c = zeros(N,1);
    for k=1:N
        c(k) = alpha*exp(-beta*(x(1 + (k-1)*mx)-lambda_t)^2)-x(5+(k-1)*mx);
    end
    ceq = [];
end