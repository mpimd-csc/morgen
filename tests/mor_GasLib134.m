%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD 2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: GasLib134 benchmark network

for s = {'imex1','imex2'}
    for m = {'ode_mid','ode_end'}
%
        morgen('GasLib134','training',m{:},s{:},{ ...
                                                  'pod_r', ...
                                                  'eds_ro', ...
                                                  'eds_wx', ...
                                                  'eds_wz', ...
                                                  'bpod_ro', ...
                                                  'ebt_ro', ...
                                                  'ebt_wx', ...
                                                  'ebt_wz', ...
                                                  'ebg_ro', ...
                                                  'ebg_wx', ...
                                                  'ebg_wz', ...
                                                  'dmd_r', ...
                                                 },'dt=20','ord=250','notest');
%
        morgen('GasLib134','rand',m{:},s{:},{ ...
                                             ['GasLib134--',m{:},'--',s{:},'--pod_r.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--eds_ro.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--eds_wx.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--eds_wz.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--bpod_ro.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--ebt_ro.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--ebt_wx.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--ebt_wz.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--ebg_ro.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--ebg_wx.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--ebg_wz.rom'], ...
                                             ['GasLib134--',m{:},'--',s{:},'--dmd_r.rom'], ...
                                            },'dt=20','ord=250','ys=-5');
%
    end%for
end%for

morgen('GasLib134','rand','ode_end','imex1',{},'dt=20');
