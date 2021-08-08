%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Test pipeline from PSI.

for s = {'imex1','imex2'}
    for m = {'ode_mid','ode_end'}
%
        morgen('pipeline','training',m{:},s{:},{ ...
                                                 'pod_r', ...
                                                 'eds_ro_l', ...
                                                 'eds_wx_l', ...
                                                 'eds_wz_l', ...
                                                 'bpod_ro_l', ...
                                                 'ebt_ro_l', ...
                                                 'ebt_wx_l', ...
                                                 'ebt_wz_l', ...
                                                 'gopod_r', ...
                                                 'ebg_ro_l', ...
                                                 'ebg_wx_l', ...
                                                 'ebg_wz_l', ...
                                                 'dmd_r', ...
                                                },'dt=10','ord=50','notest');
%
         morgen('pipeline','day',m{:},s{:},{ ...
                                                ['pipeline--',m{:},'--',s{:},'--pod_r.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--eds_ro_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--eds_wx_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--eds_wz_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--bpod_ro_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--ebt_ro_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--ebt_wx_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--ebt_wz_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--gopod_r.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--ebg_ro_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--ebg_wx_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--ebg_wz_l.rom'], ...
                                                ['pipeline--',m{:},'--',s{:},'--dmd_r.rom'], ...
                                               },'dt=10','ord=50','compact');
%
    end%for
end%for

