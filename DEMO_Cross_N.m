

% Francesco Conti, Gaetano Scarano, Stefania Colonnese, Mauro Biagi, 2021/01/04%
% Copyright: This is published under BSD BSD 3-Clause License

% Copyright (c) 2021, francescoconti748 (Francesco Conti)
% All rights reserved, see LICENSE file
%% Asymmetric Levinson and Cross-Burg - experiment 1 and 2

%Francesco Conti, Stefania Colonnese, Gaetano Scarano


close all
clear
clc

addpath([pwd, '\boxplotGroup'])
%% parameters

%parameters

L = 2*1024; %samples

nRuns = 100; %number of runs, change it in simulink Simulation time

%SNR = [ 25, 20, 15, 10]; %we re-produce results for this case
SNR = [10];

N = [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
%N = [ 2, 3, 4];

n_N = length(N);


set_param('CrossAR/ModelParameters',"Samples4Frame", num2str(L)) %set Samples4Frame in Simulink Mask parameters
set_param('CrossAR/ModelParameters','SNR_dB', num2str(SNR) )

poles_x = "[ 0.8, pi/3; 0.8, -pi/3; 0.8, pi/2; 0.8, -pi/2]"; %explicit poles as string vectors [modules_vector, phases_vector]
poles_y = "[ 0.8, pi/3; 0.8, -pi/3; 0.8, pi/2; 0.8, -pi/2]"; %exp1
%poles_y = "[ 0.8, pi/3+pi/8; 0.8, -pi/3-+pi/8; 0.8, pi/2++pi/8; 0.8, -pi/2-+pi/8]"; %exp2

set_param('CrossAR/ModelParameters',"Poles_x", poles_x) %set poles in Simulink Mask parameters
set_param('CrossAR/ModelParameters',"Poles_y", poles_y) %the mask callback automatically generates the coeffs

poles_x = eval(poles_x);
poles_y = eval(poles_y);

a_x = poly( poles_x(:, 1).*exp(1j*poles_x(:, 2) ) ); %coeffs from poles
a_y = poly( poles_y(:, 1).*exp(1j*poles_y(:, 2) ) );

roots_grt_x = roots( a_x );
roots_grt_y = roots( a_y );

%performance 
% RMSE_Burg_x = zeros( nRuns, n_SNR);
% RMSE_CrossB_x = zeros( nRuns, n_SNR);
% RMSE_Burg_y = zeros( nRuns, n_SNR);
% RMSE_CrossB_y = zeros( nRuns, n_SNR);
Pe_Burg = zeros( nRuns, n_N);
Pe_Cross = zeros( nRuns, n_N);
Px_signal = zeros( nRuns, n_N);

%N = length( poles_x );
%set_param('CrossAR/ModelParameters',"Nlags", num2str(N))


for idx_N = 1:length(N)
   
    %% Simulink call
    % Simulink model is called with a SNR value in each run
    set_param('CrossAR/ModelParameters','Nlags', num2str(N(idx_N)))
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
    
    figure( "Name", ['Channel X: SNR: ' num2str(N(idx_N))] );
    %figure( "Name", ['Channel Y: SNR: ' num2str(SNR(idx_snr))] ); 
    hold on 
    scatter( real(roots_grt_x), imag(roots_grt_x), 40, 'k', 'filled', 'o' )
    %scatter( real(roots_grt_y), imag(roots_grt_y), 40, 'k', 'filled', 'o' )

    % the scatter plot is created at running time, select which channel you
    % want to visualize uncommenting the corresponding line
    
    
    %
    for idx_run = 1:nRuns

        %Coeffs RMSE
        
%         RMSE_Burg_x(idx_run, idx_N  ) = sqrt( sum((a_x - ax_Burg(idx_run, :)).^2)/(N+1) ) ;
%         RMSE_CrossB_x(idx_run, idx_N  ) = sqrt( sum(( a_x - ax_crossB(idx_run, :)).^2)/(N+1)  );
%         
%         RMSE_Burg_y(idx_run, idx_N  ) = sqrt( sum((a_y - ay_Burg(idx_run, :)).^2)/(N+1) ) ;
%         RMSE_CrossB_y(idx_run, idx_N  ) = sqrt( sum(( a_y - ay_crossB(idx_run, :)*(flip( eye(N+1) )) ).^2)/(N+1)  );
%         
        % Roots plot
        roots_burg_x = roots( ax_Burg(idx_run, :) );
        roots_cross_x = roots( ax_crossB(idx_run, :) );
        
        roots_burg_y = roots( ay_Burg(idx_run, :) );
        roots_cross_y = roots( ay_crossB(idx_run, :)*(flip( eye(N(idx_N)+1) )) );
        
        scatter( real(roots_burg_x), imag(roots_burg_x), 10,  [0 0.4470 0.7410], "filled" )
        scatter( real(roots_cross_x), imag(roots_cross_x), 10, [0.8500 0.3250 0.0980] ,"filled"  )

        %figure(f2)
%         scatter( real(roots_burg_y), imag(roots_burg_y), 'r.' )
%         scatter( real(roots_cross_y), imag(roots_cross_y), 'g.' )
        
                       
        %Error Power
        w_run = w.Data( :, idx_run );     
   
        %x_gt = filter( 1,  ModelParam.Ax, w_run );
        x_gt = x.Data(:, idx_run);
        x_est_Burg = filter( 1, ax_B.Data( idx_run, : ), w_run ); 
        x_est_Cross = filter( 1, ax_cr.Data( idx_run, : ), w_run ); 
   
        Pe_Burg(idx_run, idx_N  ) = sum((x_gt - x_est_Burg).^2)/(length(w_run)-N(n_N)-1);
        Pe_Cross(idx_run, idx_N  ) = sum((x_gt - x_est_Cross).^2)/(length(w_run)-N(n_N)-1);   
        Px_signal(idx_run, idx_N) = sum((x_gt).^2)/length(w_run);      
       
    end
    
    %scatter( real(roots_grt_y), imag(roots_grt_y), 30, 'k', 'filled', 'o' )
    scatter( real(roots_grt_x), imag(roots_grt_x), 50, 'k', 'filled', 'o' )
    [hz1, hp1, ht1] = zplane([]);
    grid on;
    hold off
    %legend(  "GoundT" , "Burg", "Cross-Burg", 'Location', "southwest")
    legend(  "GroundT" , "Burg", "Cross-Burg", 'Location', "northeast")
    set(findobj(ht1, 'Type', 'line'), 'LineWidth', 1.5, 'Color', [0.700 0.700 0.700, 0.9]);
    set(gca,'Fontsize',16);
    
    
end

%%
%RMSE_Burg_x_mean = mean( RMSE_Burg_x );
%RMSE_CrossB_x_mean = mean( RMSE_CrossB_x );
%RMSE_CrossYW_x_mean = mean( RMSE_CrossYW_x );

%RMSE_Burg_y_mean = mean( RMSE_Burg_y );
%RMSE_CrossB_y_mean = mean( RMSE_CrossB_y );
%RMSE_CrossYW_y_mean = mean( RMSE_CrossYW_y );

%RMSE_Burg_x_var = var( RMSE_Burg_x );
%RMSE_CrossB_x_var = var( RMSE_CrossB_x );
%RMSE_CrossYW_x_var = var( RMSE_CrossYW_x );

%RMSE_Burg_y_var = var( RMSE_Burg_y );
%RMSE_CrossB_y_var = var( RMSE_CrossB_y );
%RMSE_CrossYW_y_var = var( RMSE_CrossYW_y );
    
power_ratio_Burg_mean = mean(Pe_Burg./Px_signal);
power_ratio_Burg_var =var(Pe_Burg./Px_signal ) ;
power_ratio_cross_mean = mean(Pe_Cross./Px_signal );
power_ratio_cross_var = var(Pe_Cross./Px_signal ) ;


%%

% data = { [RMSE_Burg_x(:,1), RMSE_Burg_x(:, 2), RMSE_Burg_x(:, 3), RMSE_Burg_x(:,4)], ...
%    [RMSE_CrossB_x(:,1), RMSE_CrossB_x(:, 2), RMSE_CrossB_x(:, 3), RMSE_CrossB_x(:,4) ] };
% figure
% boxplotGroup( data, 'PrimaryLabels', {'Burg', 'Cross'}, ...
%    'SecondaryLabels', {['SNR = ' num2str(SNR(1))], ['SNR = ' num2str(SNR(2))], ...
%       ['SNR = ' num2str(SNR(3))], ['SNR = ' num2str(SNR(4))]}, ...  
%       'GroupLabelType', 'Vertical', ...
%     'Colors', lines(3));
% 
%     
% grid on
% set(gca,'Fontsize',25);
% xtickangle(45)
% ylabel( "RMSE" )
% yticks([0.05, 0.15, 0.25, 0.35, 0.45])
% ytickangle(60)
% 
% %
% datay = { [RMSE_Burg_y(:,1), RMSE_Burg_y(:, 2), RMSE_Burg_y(:, 3), RMSE_Burg_y(:,4) ], ...
%    [RMSE_CrossB_y(:,1), RMSE_CrossB_y(:, 2), RMSE_CrossB_y(:, 3), RMSE_CrossB_y(:,4) ] };
% figure
% boxplotGroup( datay, 'PrimaryLabels', {'Burg', 'Cross'}, ...
%    'SecondaryLabels', {['SNR = ' num2str(SNR(1))], ['SNR = ' num2str(SNR(2))], ...
%       ['SNR = ' num2str(SNR(3))], ['SNR = ' num2str(SNR(4))]}, ...  
%       'GroupLabelType', 'Vertical', ...
%    'Colors', lines(3));
% 
%     
% grid on
% set(gca,'Fontsize',16);
% xtickangle(45)
% ylabel( "RMSE" )
% yticks([0.05, 0.15, 0.25, 0.35, 0.45])
% ytickangle(60)
% 

%%
data = { [Pe_Burg(:,1), Pe_Burg(:, 2), Pe_Burg(:, 3), Pe_Burg(:,4),  Pe_Burg(:,5),  Pe_Burg(:,6),  Pe_Burg(:,7)], ...
   [Pe_Cross(:,1), Pe_Cross(:, 2), Pe_Cross(:, 3), Pe_Cross(:,4), Pe_Cross(:,5), Pe_Cross(:,6),  Pe_Cross(:,7) ] };
figure
boxplotGroup( data, 'PrimaryLabels', {'Burg', 'Cross'}, ...
   'SecondaryLabels', {['N = ' num2str(N(1))], ['N = ' num2str(N(2))], ...
      ['N = ' num2str(N(3))], ['N = ' num2str(N(4))],  ['N = ' num2str(N(5))],  ['N = ' num2str(N(6))],  ['N = ' num2str(N(7))]}, ...  
      'GroupLabelType', 'Vertical', ...
   'Colors', lines(3));
      %'GroupLabelType', 'Vertical', ...
axis tight    
grid on
set(gca,'Fontsize',16);
xtickangle(45)
ylabel( "Error Relative Power" )


%%

AIC_Burg = log(Pe_Burg) + 2*N/L;
AIC_Cross = log(Pe_Cross) + 2*N/L;

data = { [AIC_Burg(:,1), AIC_Burg(:, 2), AIC_Burg(:, 3), AIC_Burg(:,4),  AIC_Burg(:,5),  AIC_Burg(:,6),  AIC_Burg(:,7)], ...
   [AIC_Cross(:,1), AIC_Cross(:, 2), AIC_Cross(:, 3), AIC_Cross(:,4), AIC_Cross(:,5), AIC_Cross(:,6),  AIC_Cross(:,7) ] };
figure
boxplotGroup( data, 'PrimaryLabels', {'Burg', 'Cross'}, ...
   'SecondaryLabels', {['N = ' num2str(N(1))], ['N = ' num2str(N(2))], ...
      ['N = ' num2str(N(3))], ['N = ' num2str(N(4))],  ['N = ' num2str(N(5))],  ['N = ' num2str(N(6))],  ['N = ' num2str(N(7))]}, ...  
      'GroupLabelType', 'Vertical', ...
   'Colors', lines(3));
      %'GroupLabelType', 'Vertical', ...
axis tight    
grid on
set(gca,'Fontsize',16);
xtickangle(45)
ylabel( "Error Relative Power" )


%%
figure
plot( N, mean(AIC_Burg), '-o' , 'LineWidth', 1.8)
hold on
plot( N, mean(AIC_Cross), '-o' , 'LineWidth', 1.8 )
xlabel( "N- AR order" )
ylabel("AIC")
legend( "Burg", "Cross Burg")
axis tight    
grid on
set(gca,'Fontsize',16);