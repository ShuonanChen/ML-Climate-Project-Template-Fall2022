// exact GP
functions {
	#GP 2D (analytical predicting)  # only use one alpha 
	vector gp12_pred_rng(real[] x1_grid, real[] x2_grid,
					 vector y1, real[] x1, real[] x2,
					 real alpha, real rho1, real rho2, real sigma, real delta) {
		int Nsample = rows(y1);
		int N2 = size(x1_grid);
		vector[N2] f2;
		{
		  matrix[Nsample, Nsample] K =   cov_exp_quad(x1, alpha, rho1).*cov_exp_quad(x2, 1, rho2)  ## N x N
+ diag_matrix(rep_vector(square(sigma), Nsample));
		  matrix[Nsample, Nsample] L_K = cholesky_decompose(K);

		  vector[Nsample] L_K_div_y1 = mdivide_left_tri_low(L_K, y1);
		  vector[Nsample] K_div_y1 = mdivide_right_tri_low(L_K_div_y1', L_K)';
		  matrix[Nsample, N2] k_x1_x2 = cov_exp_quad(x1, x1_grid, alpha, rho1).*cov_exp_quad(x2, x2_grid, 1, rho2);  ## N x N*
		  vector[N2] f2_mu = (k_x1_x2' * K_div_y1); //'
		  matrix[Nsample, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
		  matrix[N2, N2] cov_f2 =   cov_exp_quad(x1_grid, alpha, rho1).*cov_exp_quad(x2_grid, 1, rho2) - v_pred' * v_pred
								  + diag_matrix(rep_vector(delta, N2)); //'  N* x N*
		  f2 = multi_normal_rng(f2_mu, cov_f2);
		}
		return f2;
	}
	
	//GP 3D (analytical predicting)
	vector gp123_pred_rng(real[] x1_grid, real[] x2_grid, real[] x3_grid,
					 vector y1, real[] x1, real[] x2, real[] x3,
					 real gpscale, real rho1, real rho2, real rho3, real sigma, real delta) {
		int N_sample = rows(y1);
		int N2 = size(x1_grid);
		vector[N2] f2;
		{
		  matrix[N_sample, N_sample] K =   gp_exp_quad_cov(x1, gpscale, rho1).*gp_exp_quad_cov(x2, 1, rho2).*gp_exp_quad_cov(x3, 1, rho3)
							 + diag_matrix(rep_vector(square(sigma), N_sample));
		  matrix[N_sample, N_sample] L_K = cholesky_decompose(K);
		  vector[N_sample] L_K_div_y1 = mdivide_left_tri_low(L_K, y1);
		  vector[N_sample] K_div_y1 = mdivide_right_tri_low(L_K_div_y1', L_K)';
		  matrix[N_sample, N2] k_x1_x2 = gp_exp_quad_cov(x1, x1_grid, gpscale, rho1).*gp_exp_quad_cov(x2, x2_grid, 1, rho2).*gp_exp_quad_cov(x3, x3_grid, 1, rho3);
		  vector[N2] f2_mu = (k_x1_x2' * K_div_y1); //'
		  matrix[N_sample, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
		  matrix[N2, N2] cov_f2 =   gp_exp_quad_cov(x1_grid, gpscale, rho1).*gp_exp_quad_cov(x2_grid, 1, rho2).*gp_exp_quad_cov(x3_grid, 1, rho3) - v_pred' * v_pred
								  + diag_matrix(rep_vector(delta, N2)); //'
		  f2 = multi_normal_rng(f2_mu, cov_f2);
		}
		return f2;
	}


	# kernel 1D
	matrix ker_SE(real[] x, real sdgp, real lscale, real sigma) { 
		int n= size(x);
		matrix[n, n] cov;
		
		cov = cov_exp_quad(x, sdgp, lscale);
		
		for (i in 1:n) {
			cov[i, i] = cov[i, i] + square(sigma);
		}
		return cholesky_decompose(cov);
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

    //Kernel 3D
	matrix ker_gp123(real[] x1, real[] x2, real[] x3, real sdgp, real lscale1, real lscale2, real lscale3, real sigma) { 
		matrix[size(x1), size(x1)] cov;
		cov = gp_exp_quad_cov(x1, sdgp, lscale1).*gp_exp_quad_cov(x2, 1, lscale2).*gp_exp_quad_cov(x3, 1, lscale3);
		for (n in 1:size(x1))
			cov[n, n] = cov[n, n] + square(sigma);
		return cholesky_decompose(cov);
	}
}

data {
	int<lower=1> Nsample;
	int Npred;
	int<lower=1> D;
	vector[D] x[Nsample];
	vector[Nsample] log_y;
	vector[D] x_grid[Npred];
	//vector[Npred] y_grid;
}

transformed data{
	vector[Nsample] zeros = rep_vector(0, Nsample);
    vector[Nsample] y = exp(log_y);
    real logymean = mean(log_y);
    real logysd = sd(log_y);
    vector[Nsample] log_yn = (log_y - logymean)/logysd;
}

parameters {
	real<lower=0> rho[D];
	real<lower=0> sigma;
	real<lower=0> alpha;
}

transformed parameters{
	matrix[Nsample,Nsample] L_K;

	#Kernel 3D
	L_K = ker_gp123(x[,1], x[,2], x[,3], alpha, rho[1], rho[2], rho[3], sigma);
}

model{
	rho ~ inv_gamma(2,.5);
	sigma ~ normal(0,1);
	alpha ~ normal(0,2);
	
	log_yn ~ multi_normal_cholesky(zeros, L_K);

}

generated quantities{
	vector[Npred] f_grid;
	vector[Npred] y_grid_predict;
	vector[Npred] log_y_grid_predict;
    real pred_log_y;

	#GP 2D (Analytical prediction)
	f_grid = gp123_pred_rng(x_grid[,1], x_grid[,2], x_grid[,3], log_yn, x[,1], x[,2],  x[,3], alpha, rho[1], rho[2], rho[3], sigma, 1e-10)*logysd + logymean;
	
	
	for (i in 1:Npred){
		log_y_grid_predict[i] = normal_rng(f_grid[i], sigma); 
        y_grid_predict[i] = exp(log_y_grid_predict[i]);
		//log_y_grid_predict[i] = normal_lpdf(y_grid[i] | f_grid[i], sigma);
	}
    real sigma_N = sigma*logysd;
}