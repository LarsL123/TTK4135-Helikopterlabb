function [c, ceq] = non_linear_constraint(x, z0)
    alpha = 0.2;
    beta = 20;
    c = alpha*exp(-beta*(x(1)-z0(1))^2)-x(5);
    ceq = [];
end