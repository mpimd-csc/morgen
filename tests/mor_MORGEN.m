%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: MORGEN test network.

for s = {'imex1','imex2'}
    for m = {{'ode_mid',''},{'ode_end',''},{'ode_end','_l'}}

        if strcmp(m{1}{2},'_l'), plotid = 'lin'; else, plotid = 'non'; end%if
%
        morgen('MORGEN','training',m{1}{1},s{:},{ ...
                                                  'pod_r', ...
                                                 ['eds_ro',m{1}{2}], ...
                                                 ['eds_wx',m{1}{2}], ...
                                                 ['eds_wz',m{1}{2}], ...
                                                 ['bpod_ro',m{1}{2}], ...
                                                 ['ebt_ro',m{1}{2}], ...
                                                 ['ebt_wx',m{1}{2}], ...
                                                 ['ebt_wz',m{1}{2}], ...
                                                  'gopod_r', ...
                                                 ['ebg_ro',m{1}{2}], ...
                                                 ['ebg_wx',m{1}{2}], ...
                                                 ['ebg_wz',m{1}{2}], ...
                                                  'dmd_r', ...
                                                },'dt=60','ord=150','notest');
%
        morgen('MORGEN','day',m{1}{1},s{:},{ ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--pod_r.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--eds_ro',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--eds_wx',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--eds_wz',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--bpod_ro',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--ebt_ro',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--ebt_wx',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--ebt_wz',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--gopod_r.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--ebg_ro',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--ebg_wx',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--ebg_wz',m{1}{2},'.rom'], ...
                                            ['MORGEN--',m{1}{1},'--',s{:},'--dmd_r.rom'], ...
                                           },'dt=60','ord=150','ys=-8',['pid=',plotid]);
%
    end%for
end%for

morgen('MORGEN','day','ode_end','generic',{},'dt=60');

