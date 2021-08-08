%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Pipeline test for KoMSO Success Stories

morgen('Cha09','training','ode_mid','imex1',{ ...
                                             'pod_r', ...
                                             'eds_ro', ...
                                             'eds_wx', ...
                                             'eds_wz', ...
                                             'ebt_ro', ...
                                             'ebt_wx', ...
                                             'ebt_wz', ...
                                            },'notest');

morgen('Cha09','period','ode_mid','imex1',{ ...
                                           'Cha09--ode_mid--pod_r.rom', ...
                                           'Cha09--ode_mid--eds_ro.rom', ...
                                           'Cha09--ode_mid--eds_wx.rom', ...
                                           'Cha09--ode_mid--eds_wz.rom', ...
                                           'Cha09--ode_mid--ebt_ro.rom', ...
                                           'Cha09--ode_mid--ebt_wx.rom', ...
                                           'Cha09--ode_mid--ebt_wz.rom', ...
                                          });
