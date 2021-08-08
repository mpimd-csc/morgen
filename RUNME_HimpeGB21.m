%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Numerical experiments for HimpeGB21.

fprintf('\n');
fprintf('# Numerical Experiments for:\n\n');
fprintf(' C. Himpe, S. Grundel, P. Benner: \n');
fprintf(' "Model Order Reduction for Gas and Energy Networks";\n');
fprintf(' Journal of Mathematics in Industry 11: 13, 2021. \n\n');

addpath('tests');

mor_Cha09
mor_MORGEN
mor_GasLib134

