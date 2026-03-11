q11 = 1;
q22 = 1;
q33 = 1;
q44 = 1;

R = 0.01;

Q = diag([q11 q22 q33 q44]);
K = dlqr(A1,B1,Q,R);