function ModelParam = CrossAr_init(block)
% Francesco Conti, Gaetano Scarano, Stefania Colonnese, Mauro Biagi, 2021/01/04%
% Copyright: This is published under BSD BSD 3-Clause License

% Copyright (c) 2021, francescoconti748 (Francesco Conti)
% All rights reserved, see LICENSE file
%

 disp ([ 'Parameter Block=' block]);
 ModelParam.Samples4Frame      = eval(get_param(block, 'Samples4Frame'));
 
 ModelParam.ExcitationPow     = eval(get_param(block, 'ExcitationPow'));
 ModelParam.SigPow      = eval(get_param(block, 'SigPow'));

 ModelParam.Poles_x      = eval(get_param(block, 'Poles_x'));
 ModelParam.Poles_y      = eval(get_param(block, 'Poles_y'));
 
 ModelParam.Ax      = eval(get_param(block, 'Ax'));
 ModelParam.Ay      = eval(get_param(block, 'Ay'));
 
 ModelParam.SNR_dB   = eval(get_param(block, 'SNR_dB'));
 %ModelParam.NoisePowY     = eval(get_param(block, 'NoisePowY'));
 
 ModelParam.Nlags      = eval(get_param(block, 'Nlags'));

 
end
