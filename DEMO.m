%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Basic demonstration of simulation and model reduction.

morgen('pipeline', ...   % Network
       'day', ...        % Scenario
       'ode_end', ...    % Model
       'imex1', ...      % Solver
       { ...             % Reductors:
        'pod_r', ...      % Proper Orthogonal Decomposition (Reachability-Based)
        'eds_ro_l', ...   % Empirical Dominant Subspaces (Reachability-Observability-Based) Primal-Dual Variant
        'eds_wx_l', ...   % Empirical Dominant Subspaces (Minimality-Based) Primal-Dual Variant
        'eds_wz_l', ...   % Empirical Dominant Subspaces (Averaged-Minimality-Based) Primal-Dual Variant
        'bpod_ro_l', ...  % Balanced Proper Orthogonal Decomposition (Reachability-Observability-Based) Primal-Dual Variant
        'ebt_ro_l', ...   % Empirical Balanced Truncation (Reachability-Observability-Based) Primal-Dual Variant
        'ebt_wx_l', ...   % Empirical Balanced Truncation (Minimality-Based) Primal-Dual Variant
        'ebt_wz_l', ...   % Empirical Balanced Truncation (Averaged-Minimality-Based) Primal-Dual Variant
        'gopod_r', ...    % Goal-Oriented Proper Orthogonal Decomposition (Reachability-Based)
        'ebg_ro_l', ...   % Empirical Balanced Gains (Reachability-Observability-Based) Primal-Dual Variant
        'ebg_wx_l', ...   % Empirical Balanced Gains (Minimality-Based) Primal-Dual Variant
        'ebg_wz_l', ...   % Empirical Balanced Gains (Averaged-Minimality-Based) Primal-Dual Variant
        'dmd_r', ...      % Dynamic Mode Decomposition Galerkin (Reachability-Based)
       }, ...            % Ad-hoc configuration:
        'dt=10', ...      % Use 10s time-steps
        'ord=50', ...     % Maximum reduced order 50 (computation and evaluation)
        'compact');       % Make compact plot instead of individual plots

