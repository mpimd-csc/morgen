%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Pipeline from Cha09

for s = {'imex1','imex2'}
    for m = {{'ode_mid',''},{'ode_end',''},{'ode_end','_l'}}

        if strcmp(m{1}{2},'_l'), plotid = 'lin'; else, plotid = 'non'; end%if
%
        morgen('Cha09','training',m{1}{1},s{:},{ ...
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
                                               },'dt=20','ord=150','notest');
%
        morgen('Cha09','period',m{1}{1},s{:},{ ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--pod_r.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--eds_ro',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--eds_wx',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--eds_wz',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--bpod_ro',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--ebt_ro',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--ebt_wx',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--ebt_wz',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--gopod_r.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--ebg_ro',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--ebg_wx',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--ebg_wz',m{1}{2},'.rom'], ...
                                              ['Cha09--',m{1}{1},'--',s{:},'--dmd_r.rom'], ...
                                             },'dt=20','ord=150','ys=-14',['pid=',plotid]);
%
    end%for
end%for

morgen('Cha09','period','ode_end','generic',{},'dt=20');

