function r = cmp_compressibility(p,T,pc,Tc)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Compare compressibility factors

    r = [compressibility_ideal(p,celsius2kelvin(T),pc,celsius2kelvin(Tc)); ...
         compressibility_aga88(p,celsius2kelvin(T),pc,celsius2kelvin(Tc)); ...
         compressibility_dvgw(p,celsius2kelvin(T),pc,celsius2kelvin(Tc)); ...
         compressibility_papay(p,celsius2kelvin(T),pc,celsius2kelvin(Tc))];
end

