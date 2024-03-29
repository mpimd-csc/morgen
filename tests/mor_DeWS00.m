%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Test Belgian network from DeWS00.

for s = {'imex1','imex2','cnab2'}
    for m = {'ode_mid','ode_end'}
%
        morgen('DeWS00','training',m{:},s{:},{ ...
                                              'pod_r', ...
                                              'eds_ro', ...
                                              'eds_wx', ...
                                              'eds_wz', ...
                                              'bpod_ro', ...
                                              'ebt_ro', ...
                                              'ebt_wx', ...
                                              'ebt_wz', ...
                                              'gopod_r', ...
                                              'ebg_ro', ...
                                              'ebg_wx', ...
                                              'ebg_wz', ...
                                              'dmd_r', ...
                                             },'dt=15','ord=150','notest');
%
        morgen('DeWS00_belgium','rand',m{:},s{:},{ ...
                                          ['DeWS00--',m{:},'--',s{:},'--pod_r.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--eds_ro.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--eds_wx.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--eds_wz.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--bpod_ro.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--ebt_ro.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--ebt_wx.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--ebt_wz.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--gopod_r.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--ebg_ro.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--ebg_wx.rom'], ...
                                          ['DeWS00--',m{:},'--',s{:},'--ebg_wz.rom'], ...
                                         ['DeWS00--',m{:},'--',s{:},'--dmd_r.rom'], ...
                                        },'dt=15','ord=150','ys=-16');
%
    end%for
end%for

morgen('DeWS00','rand','ode_end','generic',{},'dt=15');

