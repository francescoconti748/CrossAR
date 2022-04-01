# CrossAR
Cross AR modeling in double channel scenarios

This repository is related to the work:
"Asymmetric Levinson Recursion and Cross-Burg Method: Noise Insensitive Single-Input Two-OutputAR Modeling"
Stefania Colonnese, Francesco Conti, Mauro Biagi, Gaetano Scarano

ArXiv:
Submitted to Signal Processing Letters

If you are using this code, please cite our work as:
S. Colonnese, F. Conti, M. Biagi and G. Scarano, "Cross-Burg Algorithm for Single-Input Two-Outputs Autoregressive Modeling," in IEEE Signal Processing Letters, vol. 28, pp. 1640-1644, 2021, doi: 10.1109/LSP.2021.3101128.


Refer to: conti.1655885@studenti.uniroma1.it

The repository contains:

1) LibCrossAr.mdl, a Simulink Model providing the library blocks implementing in MATLAB functions:
      
      1a)  The Asymmetric Levinson Recursion in AsymmLevinson;
      1b)  The Cross-Burg Method in AsymmBurg;
      
    
2) A demonstrative Simulink Model CrossAR.mdl, realizing:
    - The signals generation according to the SITO-AR model;
    - The AR modeling by applying the Burg Method on each channel;
    - The SITO-AR modeling by applying the Asymmetric Recursion on the noisy cross-correlation function;
    - The SITO-AR modeling by applying Cross-Burg to the noise observations;

    The model parameters can be set using a user interface realized as a block's mask.   
    A struct "ModelParam" is inizialazed in MATLAB's workspace at each Simulink run;
    
3) Two MATLAB Demos running the Simulink model with different parameters to reproduce results presented in our work;
    - 3a) DEMO_noise_insensitive_analysis.m;
    - 3b) DEMO_Cross_delta_analysis.m
   Please, open the CrossAR model before to run the Demo codes.
    
4) The library Adam Danz (2021), boxplotGroup
  (https://www.mathworks.com/matlabcentral/fileexchange/74437-boxplotgroup), MATLAB Central File Exchange. Retrieved January 4, 2021.
  to reproduce the plot in the paper (we acknowledge Adam Danz);
  
    
You may run our code in Simulink or you may use our DEMO as a basis to build your experience.   
    
