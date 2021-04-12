%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Basic setup script.

fprintf('\n');
fprintf('# morgen - Model Order Reduction for Gas and Energy Networks\n');
fprintf('============================================================\n');
fprintf('\n');
fprintf('## Cite as:\n\n');
fprintf('  C. Himpe, S. Grundel, P. Benner: \n');
fprintf('  "Model Order Reduction for Gas and Energy Networks"; 2021. \n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ADD FOLDERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('## Adding Folders ...\n\n');

addpath('tests');
addpath('tools');

% List available simulation tests
fprintf('  > Available Simulation Tests:\n\n');

for k = dir('tests/sim_*.m')

    fprintf('   %s\n',k.name);
end%for

fprintf('\n');

% List available model reduction tests
fprintf('  > Available Model Reduction Tests:\n\n');

for k = dir('tests/mor_*.m')

    fprintf('   %s\n',k.name);
end%for

clear k;

fprintf('\n');

