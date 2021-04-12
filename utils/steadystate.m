function steady = steadystate(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Caching steady-state computation.

    persistent T0;
    persistent Rs;
    persistent xs;
    persistent ys;
    persistent z0;
    persistent err;
    persistent iter1;
    persistent iter2;

    % Caching: Reusable steady state
    if isempty(T0) || isempty(Rs) || not((T0 == scenario.T0) && (Rs == scenario.Rs))

        clear leastnorm;

        x0 = discrete.x0;
        T0 = scenario.T0;
        Rs = scenario.Rs;
        rt = T0 * Rs;

        % Right-hand side
        b = -(discrete.B * scenario.us + discrete.F * scenario.cp);
        f = @(x,z) discrete.f(x0,x,scenario.us,rt * z);

%
%  /  0  Apq \ / ps \   /   -bpd    \
%  |         | |    | = |           |
%  \ Aqp  0  / \ qs /   \ -bqs - fq /
%
%       A        xs           b
%

        % Component extraction
        Apq = discrete.A(1:discrete.nP,discrete.nP+1:end);
        Aqp = discrete.A(discrete.nP+1:end,1:discrete.nP);
        bpd = b(1:discrete.nP);
        bqs = b(discrete.nP+1:end);

        qs = leastnorm(bpd,Apq); % Only computed once, hence first
        ps = leastnorm(bqs,Aqp); % Repeatedly computed, hence second to exploit caching

        z0 = 1.0;

        fs = f([ps;qs],z0);

        err = norm(discrete.A * [ps;qs] - b + fs);

        iter1 = 1;

        % Simple iterative steady-state refinement
        while (err > config.maxerror) && (iter1 < config.maxiter)

            ps = leastnorm(bqs - fs(discrete.nP+1:end));

            z0 = mean(config.compressibility(ps,scenario.T0));

            fs = f([ps;qs],z0);

            err = norm(discrete.A * [ps;qs] - b + fs);

            iter1 = iter1 + 1;
        end%while

        xs = [ps;qs];

        iter2 = 0;

        % IMEX-1 steady-state approximation
        if (err > config.maxerror)

            warning('off','Octave:lu:sparse_input');
            [AL,AU,AP] = lu(discrete.E(rt*z0) - config.dt * discrete.A,'vector');

            while (err > config.maxerror) && (iter2 < config.maxiter)

                ts = config.dt * (discrete.A * xs - b + fs);

                xs = xs + AU \ (AL \ ts(AP));

                fs = f(xs,z0);

                err = norm(discrete.A * xs - b + fs);

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

    if not(exist('OCTAVE_VERSION','builtin'))

        if 2 == nargin

            [Q,R,P] = qr(A',0);
        end%if
    
        x = Q * (R' \ b(P));
    else

        if 2 == nargin

            [Q,R] = qr(full(A'),0);
        end%if
    
        x = Q * (R' \ b);
    end%if
end

