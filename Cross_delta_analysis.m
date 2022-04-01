% Francesco Conti, Gaetano Scarano, Stefania Colonnese, Mauro Biagi, 2021/01/04%
% Copyright: This is published under BSD BSD 3-Clause License

% Copyright (c) 2021, francescoconti748 (Francesco Conti)
% All rights reserved, see LICENSE file
%

%% Asymmetric Levinson and Cross-Burg - experiment 1 and 2


%close all
%clear
clc

addpath([pwd, '\boxplotGroup'])
%%
%parameters
set_param('CrossAR/ModelParameters',"SNR_dB", "1000") %noise_free
%set_param('CrossAR/ModelParameters',"SNR_dB", "10") %noise condition

nRuns = 100; %number of runs, change it in simulink Simulation time
L = [2048, 10*1024]; %samples

delta = [ 0, pi/16, pi/8, 3*pi/16, pi/4]; %we re-produce results for this case
%delta = [ 3*pi/16];

n_delta = length(delta);
n_L = length(L);

RMSE_Burg_x = zeros( nRuns, n_delta*n_L);
RMSE_CrossB_x = zeros( nRuns, n_delta*n_L);
RMSE_Burg_y = zeros( nRuns, n_delta*n_L);
RMSE_CrossB_y = zeros( nRuns, n_delta*n_L);


for idx_delta = 1:n_delta
             
    poles_x = ['[ 0.8, pi/2+', num2str(delta(idx_delta))  '; 0.8, -pi/2-', num2str(delta(idx_delta)), ']' ];
    poles_y = ['[ 0.8, pi/2-', num2str(delta(idx_delta))  '; 0.8, -pi/2+', num2str(delta(idx_delta)), ']' ];

    set_param('CrossAR/ModelParameters',"Poles_x", poles_x)
    set_param('CrossAR/ModelParameters',"Poles_y", poles_y)

    poles_x = eval(poles_x);
    poles_y = eval(poles_y);
    a_x = poly( poles_x(:, 1).*exp(1j*poles_x(:, 2) ) );
    a_y = poly( poles_y(:, 1).*exp(1j*poles_y(:, 2) ) );
    roots_grt_x = roots( a_x );
    roots_grt_y = roots( a_y );

    N = length( poles_x );
    set_param('CrossAR/ModelParameters',"Nlags", num2str(N))
    
    figure( "Name", ['Channel X: delta: ' num2str(delta(idx_delta))] );
    hold on 
    scatter_obj_gt = scatter( real(roots_grt_x), imag(roots_grt_x), 40, 'k', 'filled', 'o' );
    
    
%%
    for idx_L = 1:n_L
          
    set_param('CrossAR/ModelParameters',"Samples4Frame", num2str(L(idx_L) ) ) 
    
    %% Simulink call
       
    sim("CrossAR.slx" )
    
        %simulink return the variables:
    %   - w, x and y to evaluate the prediction error powers
    %   - ax_B and ay_B, coeffs estimated by Burg
    %   - ax_crossB and ay_crossB, coeffs estimated by Cross-Burg
    
    %you can access the single indipendent run data by
    %variable.Data(:, run_idx)
    
    %% Performance evaluation
    
    ax_Burg = ax_B.Data;
    ay_Burg = ay_B.Data;

    ax_crossB = ax_cr.Data;
    ay_crossB = ay_cr.Data;
    
    %figure( "Name", ['Channel X: Delta idx ' num2str(idx_delta)] );
    %hold on 
    
    %f2 = figure( "Name", ['Channel Y: SNR: ' num2str(SNR(idx_snr))] ); 
    %hold on
    
    for idx_run = 1:nRuns

        %Coeffs RMSE
        idx = idx_delta + (idx_L-1)*n_delta;
        
        RMSE_Burg_x(idx_run, idx  ) = sqrt( sum((a_x - ax_Burg(idx_run, :)).^2)/(N+1) ) ;
        RMSE_CrossB_x(idx_run, idx  ) = sqrt( sum(( a_x - ax_crossB(idx_run, :)).^2)/(N+1)  );
        
        RMSE_Burg_y(idx_run, idx  ) = sqrt( sum((a_y - ay_Burg(idx_run, :)).^2)/(N+1) ) ;
        RMSE_CrossB_y(idx_run, idx  ) = sqrt( sum(( a_y - ay_crossB(idx_run, :)*(flip( eye(N+1) )) ).^2)/(N+1)  );
        
        % Roots Distance and plot
        roots_burg_x = roots( ax_Burg(idx_run, :) );
        roots_cross_x = roots( ax_crossB(idx_run, :) );
        
        roots_burg_y = roots( ay_Burg(idx_run, :) );
        roots_cross_y = roots( ay_crossB(idx_run, :)*(flip( eye(N+1) )) );
        
         %scatter( real(roots_burg_x), imag(roots_burg_x),  10,  [0.8706    0.8588    0.1922], "filled" )
         if( idx_L == 1 )  
            %scatter_obj_L1 = scatter( real(roots_cross_x), imag(roots_cross_x),  10,  [0.8706    0.8588    0.1922], "filled" );
            scatter_obj_L1 = scatter( real(roots_cross_x), imag(roots_cross_x),  10,  [0.8500 0.3250 0.0980], "filled" );
         else
            %scatter_obj_burg =scatter( real(roots_burg_x), imag(roots_burg_x),  10,[[0 0.4470 0.7410]],  "filled" ); 
            scatter_obj_L2 =scatter( real(roots_cross_x), imag(roots_cross_x),  10,  [ 0.1529    0.6902    0.2510], "filled" );
         end

        %figure(f2)
        
        %scatter( real(roots_burg_y), imag(roots_burg_y), 'r.' )
        %scatter( real(roots_cross_y), imag(roots_cross_y), 10, 'b' )
        
        %scatter( real(roots_burg_y), imag(roots_burg_y), 'r.' )
        %scatter( real(roots_cross_x), imag(roots_cross_x), 10, 'g' )
        
        roots_burg_x = roots( ax_Burg(idx_run, :) );
        roots_cross_x = roots( ax_crossB(idx_run, :) );
                          
       
    end
    
    
    end
    scatter( real(roots_grt_x), imag(roots_grt_x), 40, 'k', 'filled', 'o' )
    %scatter( real(roots_grt_y), imag(roots_grt_y), 30, 'filled', 'o' )
    [hz1, hp1, ht1] = zplane([]);
    grid on
    axis([-1, 0, 0, 1])
    set(findobj(ht1, 'Type', 'line'), 'LineWidth', 1.5, 'Color', [0.700 0.700 0.700, 0.9]);
    legend( [scatter_obj_gt, scatter_obj_L1, scatter_obj_L2],{"GoundT", ['L = ' num2str(L(1))], ['L = ' num2str(L(2))]} )
    %legend( [scatter_obj_gt, scatter_obj_burg, scatter_obj_L2],["GoundT", "Burg", "CrossB"] )
    set(gca, "Fontsize", 16)
end


%%


data = { [RMSE_CrossB_x(:,1), RMSE_CrossB_x(:, 2), RMSE_CrossB_x(:, 3), RMSE_CrossB_x(:,4), RMSE_CrossB_x(:,5)],  ...
    [RMSE_CrossB_x(:,6), RMSE_CrossB_x(:, 7), RMSE_CrossB_x(:, 8), RMSE_CrossB_x(:,9), RMSE_CrossB_x(:,10) ] };
figure
boxplotGroup( data, 'PrimaryLabels', {['L = ' num2str(L(1))], ['L = ' num2str(L(2))]}, ...
    'SecondaryLabels', {'$\delta = 0$', '$\delta = \frac{\pi}{8}$', ...
       '$\delta = \frac{\pi}{4}$', '$\delta = \frac{3\pi}{8}$', '$\delta = \frac{\pi}{2}$'}, ...  
       'GroupLabelType', 'Vertical', ...
     'Colors', lines(3));

grid on
set(gca,'Fontsize',24);

xtickangle(45)
ylabel( "RMSE" )