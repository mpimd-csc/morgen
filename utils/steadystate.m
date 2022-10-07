function steady = steadystate(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Caching steady-state computation.

    persistent T0;
    persistent Rs;
    persistent xs;
    persistent as;
    persistent ys;
    persistent z0;
    persistent err;
    persistent iter1;
    persistent iter2;

    % Caching: Reusable steady state
    if isempty(T0) || isempty(Rs) || ...
       not((T0 == scenario.T0) && (Rs == scenario.Rs))

        T0 = scenario.T0;
        Rs = scenario.Rs;
        rt = T0 * Rs;

        m0 = zeros(discrete.nPorts,1);
        n0 = zeros(discrete.nP+discrete.nQ,1);

        iP = 1:discrete.nP;
        iQ = discrete.nP+1:discrete.nP+discrete.nQ;

%  /  0  Apq \ / ps \   /   -bpd    \
%  |         | |    | = |           |
%  \ Aqp  0  / \ qs /   \ -bqs - fq /
%
%       A        xs           b

        % Component extraction
        Apq = discrete.A(iP,iQ);
        Aqp = discrete.A(iQ,iP);

        b = discrete.B * scenario.us + discrete.F * scenario.cp;
        bpd = b(iP);
        bqs = b(iQ);

        f = @(x,z) discrete.f(n0,x,scenario.us,m0,rt * z);

        qs = leastnorm(-bpd,Apq); % Only computed once, hence first
        ps = leastnorm(-bqs,Aqp); % Repeatedly computed, hence second to exploit caching

        z0 = 1.0;

        fs = f([ps;qs],z0);

        err = norm(discrete.A * [ps;qs] + b + fs);

        iter1 = 1;

        last_err = Inf;

        % Simple iterative steady-state refinement
        while (err > config.maxerror) && (iter1 < config.maxiter_lin) && (last_err >= err)

            ps = leastnorm(-bqs - fs(iQ));

            z0 = mean(config.compressibility(ps,scenario.T0));

            fs = f([ps;qs],z0);

            last_err = err;

            err = norm(discrete.A * [ps;qs] + b + fs);

            iter1 = iter1 + 1;
        end%while

        xs = [ps;qs];

        iter2 = 0;

        % IMEX-1 steady-state approximation
        if (err > config.maxerror)

            [AL,AU,AP] = lu(discrete.E(rt*z0) - config.dt * discrete.A,'vector');

            while (err > config.maxerror) && (iter2 < config.maxiter_non)

                ts = discrete.A * xs + b + f(xs,z0);

                ts = AU \ (AL \ ts(AP));

                xs = xs + config.dt * ts;

                err = norm(ts);

                iter2 = iter2 + 1;
            end%while
        end%if

        ys = discrete.C * xs;

        assert_warn(err > config.maxerror,['Inaccurate steady-state! (',num2str(err),' > ',num2str(config.maxerror),')']);
    end%if

    steady = struct('xs',xs, ...
                    'ys',ys, ...
                    'z0',z0, ...
                    'err',err, ...
                    'iter1',iter1, ...
                    'iter2',iter2);
end

%% Local function: leastnorm

function x = leastnorm(b,A)
% summary: QR-based least-norm solver

    persistent Q;
    persistent R;
    persistent P;

    if 2 == nargin

        if exist('OCTAVE_VERSION','builtin')  % OCTAVE

            [Q,R,P] = qr(full(A'),0);
        else                                  % MATLAB

            [Q,R,P] = qr(A',0);
        end%if
    end%if

    x = Q * (R' \ b(P));
end

