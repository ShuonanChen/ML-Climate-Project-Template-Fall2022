// exact GP
functions {
	#GP 2D (analytical predicting)  # only use one alpha 
	vector gp12_pred_rng(real[] x1_grid, real[] x2_grid,
					 vector y1, real[] x1, real[] x2,
					 real alpha, real rho1, real rho2, real sigma, real delta) {
		int Nsample = rows(y1);
		int N2 = size(x1_grid);
		vector[N2] mu;
		{
		  matrix[Nsample, Nsample] K =   cov_exp_quad(x1, alpha, rho1).*cov_exp_quad(x2, 1, rho2)  ## N x N
+ diag_matrix(rep_vector(square(sigma), Nsample));
		  matrix[Nsample, Nsample] L_K = cholesky_decompose(K);
		  vector[Nsample] L_K_div_y1 = mdivide_left_tri_low(L_K, y1);
		  vector[Nsample] K_div_y1 = mdivide_right_tri_low(L_K_div_y1', L_K)';
		  matrix[Nsample, N2] k_x1_x2 = cov_exp_quad(x1, x1_grid, alpha, rho1).*cov_exp_quad(x2, x2_grid, 1, rho2);  ## N x N*
		  vector[N2] f2_mu = (k_x1_x2' * K_div_y1); //'
		  matrix[Nsample, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
		  matrix[N2, N2] cov_f2 = cov_exp_quad(x1_grid, alpha, rho1).*cov_exp_quad(x2_grid, 1, rho2) - v_pred' * v_pred
								  + diag_matrix(rep_vector(delta, N2)); //'  N* x N*
		  mu = multi_normal_rng(f2_mu, cov_f2);
		}
		return mu;
	}
	
	#Kernel 2D
	matrix ker_gp12(real[] x1, real[] x2, real sdgp, real lscale1, real lscale2, real sigma) { 
		matrix[size(x1), size(x1)] cov;
		cov = cov_exp_quad(x1, sdgp, lscale1).*cov_exp_quad(x2, 1, lscale2);
		for (n in 1:size(x1)) {
			cov[n, n] = cov[n, n] + square(sigma);
		}
		return cholesky_decompose(cov);
	}
}

data {
	int<lower=1> Nsample;
	int Npred;
	int<lower=1> D;
	vector[2] x[Nsample];
    vector[D] z[Nsample];
	vector[Nsample] log_y;
	vector[2] x_grid[Npred];
    vector[D] z_grid[Npred];
}

transformed data{
	vector[Nsample] zeros = rep_vector(0, Nsample);
    vector[Nsample] y = exp(log_y);
    # real logymean = mean(log_y);
    # real logysd = sd(log_y);
    # vector[Nsample] log_yn = (log_y - logymean)/logysd;
}

parameters {
	real<lower=0> rho[2];
    row_vector[D] beta;
	real<lower=0> sigma;
    real<lower=0> eta;
	real<lower=0> alpha[2];
    vector[Nsample] f;
}

transformed parameters{
	vector[Nsample] g;
    vector[Npred] g_grid;
    matrix[Nsample,Nsample] L_K;
	L_K = ker_gp12(x[,1], x[,2], alpha[1], rho[1], rho[2], sigma);
    for (i in 1:Nsample){
      g[i] = beta*z[i];
    }
    for (i in 1:Npred){
      g_grid[i] = beta*z_grid[i];
    }
}

model{
	rho ~ inv_gamma(2,.5);
	sigma ~ normal(0,1);
    eta ~ normal(0,1);
	alpha ~ normal(0,2);
    beta ~ normal(0,2);    
    f ~ multi_normal_cholesky(zeros, L_K);
    log_y ~ normal(f + g, eta);
}

generated quantities{
	vector[Npred] f_grid;
	vector[Npred] y_grid_predict;
	vector[Npred] log_y_grid_predict;
    real pred_log_y;

	#GP 2D (Analytical prediction)
	f_grid = gp12_pred_rng(x_grid[,1], x_grid[,2], log_y - g, x[,1], x[,2], alpha[1], rho[1], rho[2], sigma, 1e-10);
    
	for (i in 1:Npred){
		log_y_grid_predict[i] = normal_rng(f_grid[i] + g_grid[i], sigma); 
        y_grid_predict[i] = exp(log_y_grid_predict[i]);
	}
}