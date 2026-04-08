% TTK4135 - Helicopter lab
% Hints/template for problem 2.
% Updated spring 2018, Andreas L. Flåten
%% Initialization and model definition
init; % Change this to the init file corresponding to your helicopter

% Discrete time system model. x = [lambda r p p_dot e e_dot]'
delta_t	= 0.25; % sampling time
A1 = [1 delta_t 0 0 0 0;
      0 1 -delta_t*K_2 0 0 0;
      0 0 1 delta_t 0 0;
      0 0 (-delta_t*K_1*K_pp) (1-delta_t*K_1*K_pd) 0 0;
      0 0 0 0 1 delta_t;
      0 0 0 0 -K_3*K_ep*delta_t (1-K_3*K_ed*delta_t)];
B1 = [0 0 0 delta_t*K_1*K_pp 0 0;
      0 0 0 0 0 K_3*K_ep*delta_t]';

% Finding LQR parameters
q11 = 1;
q22 = 1;
q33 = 1;
q44 = 1;
q55 = 1;
q66 = 1;
r1 = 0.1;
r2 = 0.1;

Q = diag([q11 q22 q33 q44 q55 q66]);
R = diag([r1 r2]);
K = dlqr(A1,B1,Q,R);
  
  
% Number of states and inputs
mx = size(A1,2); % Number of states (number of columns in A)
mu = size(B1,2); % Number of inputs(number of columns in B)

% Initial values
x1_0 = pi;                               % Lambda
x2_0 = 0;                               % r
x3_0 = 0;                               % p
x4_0 = 0;                               % p_dot
x5_0 = 0;
x6_0 = 0;
x0 = [x1_0 x2_0 x3_0 x4_0 x5_0 x6_0]';           % Initial values

% Time horizon and initialization
N  = 40;                                  % Time horizon for states
M  = N;                                 % Time horizon for inputs
z  = zeros(N*mx+M*mu,1);                % Initialize z for the whole horizon
z0 = z;                                 % Initial value for optimization

% Bounds
ul 	    = -60*pi/360;                   % Lower bound on control
uu 	    = 60*pi/360;                   % Upper bound on control

xl      = -Inf*ones(mx,1);              % Lower bound on states (no bound)
xu      = Inf*ones(mx,1);               % Upper bound on states (no bound)
xl(3)   = ul;                           % Lower bound on state x3
xu(3)   = uu;                           % Upper bound on state x3

% Generate constraints on measurements and inputs
[vlb,vub]       = gen_constraints(N,M,xl,xu,ul,uu); % hint: gen_constraints
vlb(N*mx+M*mu)  = 0;                    % We want the last input to be zero
vub(N*mx+M*mu)  = 0;                    % We want the last input to be zero

% Generate the matrix Q and the vector c (objecitve function weights in the QP problem) 
Q1 = zeros(mx,mx);
Q1(1,1) = 2;                            % Weight on state x1
Q1(2,2) = 0;                            % Weight on state x2
Q1(3,3) = 0;                            % Weight on state x3
Q1(4,4) = 0;                            % Weight on state x4
Q1(5,5) = 0;
Q1(6,6) = 0;
P1 = 1;                                 % Weight on input
P2 = 1;
Q = gen_q(Q1,P1,P2,N,M);                                  % Generate Q, hint: gen_q
c = zeros(mx*N+M*mu,1);                                  % Generate c, this is the linear constant term in the QP

%% Generate system matrixes for linear model
Aeq = gen_aeq(A1, B1, N, mx,mu);             % Generate A, hint: gen_aeq
beq = zeros(N*mx,1);                         % Generate b CHECK HERE
beq(1,1) = x1_0; %+delta_t*x1_0; 

fun = @(x)x'*Q*x;

%[c, ceq] = non_linear_constraint(z0)
%size(z0)
%size(c)
%size(ceq)


%% Solve QP problem with linear model
opt = optimoptions('fmincon', 'Algorithm','sqp','MaxFunEvals',40000);
tic
[z,lambda] =  fmincon(fun,z0,[],[],Aeq,beq,vlb,vub,@(x) non_linear_constraint(x,mx,N),opt); %quadprog(Q,c,[],[],Aeq,beq,vlb,vub) ; % hint: quadprog. Type 'doc quadprog' for more info 
t1=toc;


% Calculate objective value
phi1 = 0.0;
PhiOut = zeros(N*mx+M*mu,1);
for i=1:N*mx+M*mu
  phi1=phi1+Q(i,i)*z(i)*z(i);
  PhiOut(i) = phi1;
end

%% Extract control inputs and states
u1  = [z(N*mx+1:mu:N*mx+M*mu)]; % Control input from solution
u2 = [z(N*mx+2:mu:N*mx+M*mu)];        

x1 = [x0(1);z(1:mx:N*mx)];              % State x1 from solution
x2 = [x0(2);z(2:mx:N*mx)];              % State x2 from solution
x3 = [x0(3);z(3:mx:N*mx)];              % State x3 from solution
x4 = [x0(4);z(4:mx:N*mx)];              % State x4 from solution
x5 = [x0(5);z(5:mx:N*mx)];
x6 = [x0(6);z(6:mx:N*mx)];

num_variables = 5/delta_t;
zero_padding = zeros(num_variables,1);
unit_padding  = ones(num_variables,1);

u1   = [zero_padding; u1; zero_padding];
u2   = [zero_padding; u2; zero_padding];
x1  = [pi*unit_padding; x1; zero_padding];
x2  = [zero_padding; x2; zero_padding];
x3  = [zero_padding; x3; zero_padding];
x4  = [zero_padding; x4; zero_padding];
x5  = [zero_padding; x5; zero_padding];
x6  = [zero_padding; x6; zero_padding];

%% Plotting
t = 0:delta_t:delta_t*(length(u1)-1);

u1_timeseries = timeseries(u1,t);
u2_timeseries = timeseries(u2,t);

tx = 0:delta_t:delta_t*(length(x1)-1);
x1_timeseries = timeseries(x1,tx);
x2_timeseries = timeseries(x2,tx);
x3_timeseries = timeseries(x3,tx);
x4_timeseries = timeseries(x4,tx);

tx = 0:delta_t:delta_t*(length(x5)-1);
x5_timeseries = timeseries(x5,tx);
x6_timeseries = timeseries(x6,tx);
figure(2)
subplot(811)
stairs(t,u1),grid
ylabel('u1')
subplot(812)
stairs(t,u2),grid
ylabel('u2')
subplot(813)

t = 0:delta_t:delta_t*(length(x1)-1);
plot(t,x1,'m',t,x1,'mo'),grid
ylabel('lambda')
subplot(814)
plot(t,x2,'m',t,x2','mo'),grid
ylabel('r')
subplot(815)
plot(t,x3,'m',t,x3,'mo'),grid
ylabel('p')

subplot(816)
plot(t,x4,'m',t,x4','mo'),grid
xlabel('tid (s)'),ylabel('pdot')


subplot(817)
plot(t,x5,'m',t,x5','mo'),grid
xlabel('tid (s)'),ylabel('e')
subplot(818)
plot(t,x6,'m',t,x6','mo'),grid
xlabel('tid (s)'),ylabel('e_dot')
