![morgen logo](morgen.png) morgen - Model Order Reduction for Gas and Energy Networks (1.2)
===========================================================================================

**morgen** is an open-source MATLAB and OCTAVE test platform to compare models,
solvers, and model reduction methods (reductors) for gas networks and other
energy network systems that are based on the (isothermal) Euler equations.

## Version

Current Version: [morgen 1.2](https://doi.org/10.5281/zenodo.7157808) (2022-10-07)

## Compatibility

* Mathworks [MATLAB](https://www.mathworks.com/products/matlab.html) >= 2020b
* GNU [Octave](https://octave.org) >= 6.1

## Dependencies

* [emgr](https://gramian.de) == 5.99 (included, see `reductors/private`)

## License

**morgen** is licensed under the [BSD-2-Clause](https://opensource.org/licenses/BSD-2-Clause) license,
with copyright (c) 2020--2022: _Christian Himpe_, _Sara Grundel_; see [LICENSE](LICENSE).

## Disclaimer

**morgen** is research software.

## Citation

Please cite the **morgen** platform via its companion paper:

C. Himpe, S. Grundel, P. Benner:
**Model Order Reduction for Gas and Energy Networks**;
Journal of Mathematics in Industry 11: 13, 2021.
[doi:10.1186/s13362-021-00109-4](https://doi.org/10.1186/s13362-021-00109-4)

You can link to **morgen** via: [git.io/morgen](https://git.io/morgen)

## Getting Started

To setup simulation and reduction tests and demos:

```
> SETUP % adds the "tests" folder to the path and lists scripts
```

Tests can then be called directly as listed. To try **morgen**:

```
> DEMO  % runs a sample pipeline model reduction code
```

### Reproducibility

To reproduce the experiments from the companion paper,
**Model Order Reduction for Gas and Energy Networks**, run:

```
> RUNME_HimpeGB21
```

To reproduce the experiments from the first add-on paper,
**Next-Gen Gas Network Simulation**, run:

```
> RUNME_HimpeGB22
```

To reproduce the experiments from the second add-on paper,
**System Order Reduction for Gas and Energy Networks**, run:

```
> RUNME_HimpeG22
```

### Extending **morgen**

**morgen**'s modules can be easily extended in the following ways:

* to add a new model, see and modify: `models/template_model.m`
* to add a new solver, see and modify: `solvers/template_solver.m`
* to add a new reductor, see and modify: `reductors/template_reductor.m`
* to add a new network, see and modify: `networks/template_network.net`
* to add a new scenario, see and modify: `networks/template_network/training.ini`
* to add a new simulation test, see and modify: `tests/sim_template.m`
* to add a new reduction test, see and modify: `tests/mor_template.m`

## Usage

### Main Function

<details><summary markdown="span">(click to expand)</summary>

The **morgen** platform is called via the `morgen.m` function:

```
R = morgen(network_id,scenario_id,model_id,solver_id,reductor_ids,varargin)
```

and has four mandatory arguments:

* `network_id`   (**string**) The network identifier
* `scenario_id`  (**string**) The scenario identifier
* `model_id`     (**string**) The model identifier
* `solver_id`    (**string**) The solver identifier

as well as an optional argument and an additional variable length argument list:

* `reductor_ids` (**cell**) An array of reductor identifiers (can be empty, too)
* `varargin`     Variable argument list each containing a string (see below)

All admissible additional (**string**) arguments are described below:

* `dt=X`    - Override time step in configuration with X (in seconds)
* `tf=X`    - Override tunable efficiency factor in configuration with X (positive real)
* `ys=X`    - Force minimum y-scale for error plots with 10^X (default: -16)
* `ord=X`   - Override maximum reduced order in configuration with X (natural number)
* `pid=X`   - Add custom string identifier to plot files (default: '')
* `notest`  - Do not test the reduced order models
* `compact` - Display plots all in one figure

The `morgen.m` function returns a structure `R` with members depending on the arguments.
If only reduced order models are computed:

* `.reductors` (**cell**) Array of strings with names of the reductors
* `.offline`   (**cell**) Array of offline times for the reductors

If reduced order models are computed and tested:

* `.name`      (**string**) Output name of the experiment (as used by saved plots and scores)
* `.reductors` (**cell**) Array of strings with names of the reductors
* `.orders`    (**vector**) The tested reduced orders
* `.l0error` , `.l1error` , `.l2error` , `.l8error` (**cell**) Arrays of per reduced order average errors
* `.l0score` , `.l1score` , `.l2score` , `.l8score` (**cell**) Arrays of per reduced order average [MORscore](https://doi.org/10.1007/978-3-030-72983-7_7)s
* `.offline`   (**cell**) Array of offline times for the reductors
* `.online`    (**cell**) Array of average relative online times for the reductors
* `.breven`    (**cell**) Array of average relative offline/online break even numbers

If only a simulation is run, `R` is a matrix,
and contains the discrete output trajectory with dimensions outputs-times-time-steps.

</details>

### Network

<details><summary markdown="span">(click to expand)</summary>

A network is described by a (directed) graph, given through an edgelist,
which also specifies its edge type, and their physical dimensions and properties.

#### Network Topology Rules

* A network must have at least one supply node!
* All boundary nodes (supply or demand) must connect by exactly one edge!
  * Short pipes can be inserted to enforce this.
* The edge from a supply node must be directed away from it!
  * Hence, no two supply nodes can be directly connected.
* The edge to a demand node must be directed toward it!
  * Hence, no two demand nodes can be directly connected.

#### Available Networks

All available network datasets are listed with the network's number of

* internal junction nodes (`n0`),
* supply boundary nodes (`nS`), and
* demand boundary nodes (`nD`).

##### Test Networks

* `diamond`  - Diamond Network     (`n0=8, nS=1, nD=1, nC=0`)
* `fork1`    - Forked Pipeline     (`n0=12, nS=1, nD=2, nC=0`)
* `fork2`    - Forked Pipeline     (`n0=12, nS=2, nD=1, nC=0`)
* `comptest` - Compressor Test     (`n0=1, nS=1, nD=1, nC=1`)
* `paratest` - Parallel Pipes Test (`n0=2, nS=1, nD=1, nC=0`)
* `PamDB16`  - Triangle Network    (`n0=0, nS=1, nD=2, nC=0`)

##### Synthetic Networks

* `MORGEN`      - Small Network  (`n0=27, nS=2, nD=4, nC=1`)
* `AzeJ07`      - Small Network  (`n0=5, nS=1, nD=2, nC=1`)
* `GruHKetal13` - Small Network  (`n0=11, nS=1, nD=8, nC=0`)
* `Kiu94`       - Small Network  (`n0=8, nS=1, nD=14, nC=0`)
* `GruJHetal14` - Medium Network (`n0=45, nS=4, nD=2, nC=0`)
* `GasLib11`    - Medium Network (`n0=6, nS=3, nD=3, nC=2`)
* `GasLib24`    - Medium Network (`n0=14, nS=3, nD=5, nC=3`)
* `GasLib40`    - Medium Network (`n0=40, nS=3, nD=29, nC=6`)
* `GasLib135`   - Medium Network (`n0=135, nS=3, nD=45, nC=29`)
* `PelLL17a`    - Medium Network (`n0=41, nS=1, nD=15, nC=5`)

##### Pipelines

* `pipeline` - Pipeline (`n0=0, nS=1, nD=1, nC=0`)
* `Cha09`    - Pipeline (`n0=0, nS=1, nD=1, nC=0`)
* `RodS18`   - Tree     (`n0=6, nS=1, nD=4, nC=0`)
* `Guy67`    - Tree     (`n0=8, nS=1, nD=8, nC=0`)
* `LotH67a`  - Pipeline (`n0=0, nS=1, nD=1, nC=0`)
* `LotH67b`  - Pipeline (`n0=0, nS=1, nD=1, nC=0`)
* `LotH67c`  - Tree     (`n0=6, nS=2, nD=2, nC=2`)
* `LotH67d`  - Tree     (`n0=4, nS=2, nD=2, nC=1`)

##### Realistic Networks

* `AzePA19`     - Portugal (`n0=0, nS=1, nD=1, nC=0`)
* `BerS19`      - Spain    (`n0=6, nS=1, nD=5, nC=0`)
* `DeWS00`      - Belgium  (`n0=20, nS=6, nD=9, nC=0`)
* `EkhDLetal19` - Ireland  (`n0=26, nS=3, nD=10, nC=0`)
* `GasLib134`   - Greece   (`n0=134, nS=3, nD=45, nC=1`)
* `GasLib582`   - Germany  (`n0=582, nS=31, nD=129, nC=5`)
* `GasLib4197`  - Germany  (`n0=4197, nS=11, nD=1009, nC=12`)
* `SciGrid_NO`  - Norway   (`n0=44, nS=11, nD=9, nC=0`)
* `JinW`        - China    (`n0=45, nS=5, nD=3, nC=38`)

#### Data Origin

The GasLib network data-sets are derived from:

M. Schmidt, D. Aßmann, R. Burlacu, J. Humpola, I. Joormann, N. Kanelakis,
T. Koch, D. Oucherif, M.E. Pfetsch, L. Schewe, R. Schwarz, M. Sirvent:
**GasLib - A Library of Gas Network Instances**;
Data 2(4): 40, 2017.

and licensed under **CC-BY 3.0**, see: https://gaslib.zib.de

The SciGrid network data-sets are derived from:

J. Dasenbrock, J. Diettrich, A. Pluta, W. Medjroubi:
**SciGRID_gas NO_Raw**;
Zenodo: 10.5281/zenodo.3985268, 2020.

and licensed under **CC-BY 4.0**, see: https://www.gas.scigrid.de

#### File Format

A network is encoded in a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values)
file with the file extension `.net`. The first line is a comment header with a
description of the columns, their meaning, and units.
```
# type, identifier-in, identifier-out, pipe-length [m], pipe diameter [m], height difference [m], pipe roughness [m]
```
Each line below the first holds one edge definition with the columns:

* Edge type (`P`:pipe, `S`:shortpipe, `C`:compressor, `V`:valve)
* Start node identifier (positive integer)
* End node identifier (positive integer)
* Pipe length [`m`] (positive real)
* Pipe diameter [`m`] (positive real)
* Pipe height difference [`m`] (positive real)
* Pipe roughness [`m`] (positive real)

Thus, the gas network's directed graph is represented as an edge list,
whereas the edge directions are not corresponding to flow directions except for boundary nodes.
Note, currently only positive integers can be used as start and end identifiers.

#### Parsed Network Structure

A parsed network `.net` file is given as a `network` structure with members:

* `network`        (**struct**)
  * `.length`      (**vector**) Pipe lengths
  * `.incline`     (**vector**) Pipe inclines
  * `.diameter`    (**vector**) Pipe diameters
  * `.roughness`   (**vector**) Pipe roughnesses
  * `.nomLen`      (**vector**) Per pipe length
  * `.A0`          (**matrix**) Incidence matrix reduced by supply nodes
  * `.Ac`          (**matrix**) Incidence matrix of only compressor outlet nodes 
  * `.Bs`          (**matrix**) Incidence matrix of supply nodes
  * `.Bd`          (**matrix**) Incidence matrix of demand nodes
  * `.Fc`          (**vector**) Load vector of compressors
  * `.nEdges`      (**scalar**) Number of edges
  * `.nSupply`     (**scalar**) Number of supply nodes
  * `.nDemand`     (**scalar**) Number of demand nodes
  * `.nInternal`   (**scalar**) Number of internal nodes
  * `.nCompressor` (**scalar**) Number of compressors

</details>

### Scenario

<details><summary markdown="span">(click to expand)</summary>

A scenario data set describes the boundary values and external inhomogeneities of the gas net.
Transient behaviour of supply and demand functions is represented as step functions in compressed form by only marking changes.
Each network has a training scenario (`training.ini`), which has constant boundary values for reduced order model assembly.

#### File Format

A scenario is encoded in an [INI](https://en.wikipedia.org/wiki/INI_file) file,
with the extension `.ini`. Each line holds a key-value pair, for the following keys:

* `T0` - Average ambient temperature [`C`]
* `Rs` - Average specific gas constant [`J/(kg*K)`]
* `tH` - Time horizon [`s`]
* `vs` - Valve setting [`1`] (pipe separated list of {0,1}) {UNDER CONSTRUCTION, currently treated as short pipe}
* `cp` - Compressor (output) pressure [`bar`] (pipe separated list)
* `up` - Supply pressure changes [`bar`] (pipe separated list of semi-colon separated series)
* `uq` - Demand flow changes [`kg/s`] (pipe separated list of semi-colon separated series)
* `ut` - Time markers for changes in `up` and `uq` [s]

#### Parsed Scenario Structure

A parsed network `.ini` file is given as:

* `scenario` (**struct**)
  * `.T0`    (**scalar**) Global mean temperature
  * `.Rs`    (**scalar**) Global mean specific gas constant
  * `.tH`    (**scalar**) Time horizon
  * `.us`    (**vector**) Steady-state input
  * `.ut`    (**handle**) Function handle with signature u_t = ut(t)
  * `.cp`    (**vector**) Compressor outlet pressures

</details>

### Model

<details><summary markdown="span">(click to expand)</summary>

A model encodes a spatially discrete input-output system of the form:

```
E(p) x'(t) = A x(t) + B u(t) + F c_p + f(x(t),u(t),p)

      y(t) = C x(t)
```

which consists of an implicit nonlinear ordinary differential equation,
and an (uni-directionally coupled algebraic) output equation.

#### Interface

`discrete = model(network,config)`

#### Arguments

* `network`   (**struct**) Parsed network structure
* `config`    (**struct**) Configuration structure

#### Returns

* `discrete`  (**struct**) (Semi-)Discrete model structure
  * `.nP`     (**scalar**) Number of pressure states
  * `.nQ`     (**scalar**) Number of mass-flux states
  * `.nPorts` (**scalar**) Number of ports
  * `.E`      (**handle**) Mass matrix function handle `E_rtz = E(rtz)`
  * `.A`      (**matrix**) System matrix
  * `.B`      (**matrix**) Input matrix (models boundary nodes)
  * `.F`      (**matrix**) Source matrix (models the compressor action)
  * `.C`      (**matrix**) Output matrix (sensors at boundary nodes)
  * `.f`      (**handle**) Nonlinear vector field `x = f(xs,x,us,u,rtz)`
  * `.J`      (**handle**) Jacobian `x = J(xs,x,u,rtz)`
  * `.dual`    (**bool**)  This is only a member (of any value) if it is a dual model!

#### Available Models

* `ode_mid` - ODE model using the mid-point discretization
* `ode_end` - ODE model using the end-point discretization (port-Hamiltonian)

#### Notes

* The argument `xs` is the steady state computed in the solver (wrapper).
* The argument `x` in nonlinearity `f` and Jacobian `J` refers to the difference to the steady-state.
  This means `xs + x` yields the actual state.
* Only the components `E`, `f` and `J` are parametrized.
  Particularly, `A` and `B` do not depend on the parameter.
* Compressors can only be operated in discharge pressure control mode.
* The argument `rtz` is the product `Rs*T0*z0` formed in the solver.

</details>

### Solver

<details><summary markdown="span">(click to expand)</summary>

A solver is a time stepper that simulates a trajectory of a model and a scenario.
The prerequisite steady-state initial value is computed from the scenario's boundary values.

#### Interface

`solution = solver(discrete,scenario,config)`

#### Arguments

* `discrete` (**struct**) Discrete model structure
* `scenario` (**struct**) Scenario structure
* `config`   (**struct**) Configuration structure

#### Returns

* `solution`       (**struct**)
  * `t`            (**vector**) Time-steps vector
  * `u`            (**matrix**) Discrete inputs-times-steps trajectory
  * `y`            (**matrix**) Discrete outputs-times-steps trajectory
  * `steady_z0`    (**scalar**) Global average compressibility
  * `steady_error` (**scalar**) Steady-state error
  * `steady_iter1` (**scalar**) Algebraic steady-state iterations
  * `steady_iter2` (**scalar**) Differential steady-state iterations
  * `runtime`      (**scalar**) Transient solver runtime

#### Available Solvers

* `imex1`      - First-order implicit-explicit solver
* `imex2`      - Second-order implicit-explicit Runge-Kutta solver
* `cnab2`      - Second-order Crank-Nicolson-Adams-Bashforth solver
* `rk4`        - Fourth-order "classic" explicit Runge-Kutta solver (unstable, use only for testing)
* `rk2hyp`     - Second-order explicit Runge-Kutta solver (increased hyperbolic stability)
* `rk4hyp`     - Fourth-order explicit Runge-Kutta solver (increased hyperbolic stability)
* `generic`    - Second-order implicit adaptive `ode23s` Rosenbrock solver

* `linear_export` - Linearize and export state-space model (wraps `imex1` solver)

#### Model Export

The `linear_export` "solver" is not an actual solver,
but exports a linearization with fixed parametrization:
```
E x'(t) = A x(t) + B u(t) + F,

   y(t) = C x(t),
```
of the selected network-scenario as a `(E,A,B,C,F)` state-space model, with
the load vector `F` jointly describing the compressors, steady-state, and
steady-state effects:
```
F := F * c_p + A * xs + B * us.
```
These sparse system matrices are stored in a `.mat` file and named
`network_id--scenario_id--IySxOy.mat`, where `y` is the number of boundary ports
(inputs and outputs), and `x` is the discretized state-space dimension.

* Internally, `linear_export` calls the `imex1` solver to return a solution.

* For the `linear_export` "solver", the `model_gravity` configuration should be
  set to `none`.

* To obtain a `(E,A,B,C)` system, the load vector `F` can be concatenated to the
  input matrix `B`, i.e.: `B' := [B, F]`, incrementing the number of inputs.

</details>

### Reductors

<details><summary markdown="span">(click to expand)</summary>

A reductor computes a reduced order discrete model, aiming to approximate the
input-output (boundary-quantity-of-interest) behavior.

#### Interface

`[proj,name] = reductor(solver,discrete,scenario,config)`

#### Arguments

* `solver`   (**handle**) Solver procedure handle
* `discrete` (**struct**) Discrete model structure
* `scenario` (**struct**) Scenario structure
* `config`   (**struct**) Configuration structure

#### Returns

* `proj`  (**cell**)  Array of projectors `{LP,RP;LQ,RQ}` (Bi-Orthogonal / Oblique) or `{LP;LQ}` (Orthogonal)
* `name` (**string**) Detailed name of reductor

#### Available Reductors

These structured reductors approximate pressure and mass-flux components
separately ("Structured" is abbreviated as "Struct."):

* `pod_r`                 _Struct. Proper Orthogonal Decomposition_
* `eds_ro` / `eds_ro_l`   _Struct. Empirical Dominant Subspaces_
* `eds_wx` / `eds_wx_l`   _Struct. Empirical Cross-Gramian-Based Dominant Subspaces_
* `eds_wz` / `eds_wz_l`   _Struct. Empirical Non-Symmetric-Cross-Gramian-Based Dominant Subspaces_
* `mpod_ro` / `mpod_ro_l` _Struct. Modified Proper Orthogonal Decomposition_
* `mpod_wx` / `mpod_wx_l` _Struct. Modified Proper Orthogonal Decomposition_
* `mpod_wz` / `mpod_wz_l` _Struct. Modified Proper Orthogonal Decomposition_
* `bpod_ro` / `bpod_ro_l` _Struct. Empirical Balanced Proper Orthogonal Decomposition_
* `ebt_ro` / `ebt_ro_l`   _Struct. Empirical Balanced Truncation_
* `ebt_wx` / `ebt_wx_l`   _Struct. Empirical Cross-Gramian-Based Balanced Truncation_
* `ebt_wz` / `ebt_wz_l`   _Struct. Empirical Non-Symmetric-Cross-Gramian-Based Balanced Truncation_
* `gopod_r`               _Struct. Goal-Oriented Proper Orthogonal Decomposition_
* `ebg_ro` / `ebg_ro_l`   _Struct. Empirical Balanced Gains_
* `ebg_wx` / `ebg_wx_l`   _Struct. Empirical Cross-Gramian-Based Balanced Gains_
* `ebg_wz`  /`ebg_wz_l`   _Struct. Empirical Non-Symmetric-Cross-Gramian-Based Balanced Gains_
* `dmd_r`                 _Struct. Dynamic Mode Decomposition Galerkin_

All reductors utilizing observability information are available in two variants.
By default the nonlinear variant (no suffix) is used. The `_l` suffix signifies
a "linear" variant of the reductor, which assumes a dual system is available.
While either method can be applied to both, `ode_mid` and `ode_end`, models,
theory suggest to use the linear variant only with the port-Hamiltonian `ode_end`.

</details>

### Tests

<details><summary markdown="span">(click to expand)</summary>

A test defines an experiment, which is implemented as a script whose filename
consists of a prefix and the tested network's name. Two types of experiments are
currently implemented:

* A simulation experiment is prefixed with `sim_` and executes the `morgen.m`
  function for combinations of models and solvers against a fixed network and
  scenario.

* A model order reduction experiment is prefixed with `mor_` and executes the
  `morgen.m` function for combinations of models, solvers and reductors against
  a network and scenario while using the `training.ini` scenario for computing
  the reduced order model.

Note that tests can only be called from the **morgen** base directory,
after running the `SETUP` script, or manually adding the `tests` folder to the path:
```
addpath('tests');
```

#### Available Tests

The available experiments are listed by running the `SETUP` script,
which lists the contents of the `tests` folder.

#### Reduced Order Models

Reduced order models are saved in the `z_roms` folder (or the folder specified
by the `morgen_roms` configuration entry).

A reduced order model is saved by storing the projectors and encoding the
associated: network, model, and reductor in the filename as follows:

`network--model--reductor--pid.rom`

with `pid` being custom identifier configurable via optional arguments.

To load a reduced order model provide a filename of a saved reduced order model
instead of the reductor identifier.

#### Results 

Plots and MORscores computed by `morgen.m` are stored in the `z_plots` folder
(or the folder specified by the `morgen_plots` configuration entry).

#### MORscore

The [MORscore](https://doi.org/10.1007/978-3-030-72983-7_7) is a benchmark index
measuring the area above the model reduction error graph, which is also plotted.
This score jointly assesses the model reduction goals of minimum size and maximum accuracy.
Unstable reduced order models are counted as evaluated with relative error of `1.0`.

</details>

## Configuration

<details><summary markdown="span">(click to expand)</summary>

The **morgen** platform assumes a configuration [INI](https://en.wikipedia.org/wiki/INI_file)-file
in the base folder named `morgen.ini`, if not found hard-coded default values
are used.

* `morgen_plots` (**String**) Folder to store plots, default: `z_plots`
* `morgen_roms`  (**String**) Folder to store reduced order models, defaut: `z_roms`

* `network_dt`   (**Positive float**) Requested time step width in seconds, default: `60.0`
* `network_vmax` (**Positive float**) Maximum velocity of gas in meters per second, default: `20.0`
* `network_cfl`  (**Positive float**) Target CFL constant of spatial discretization, default: `0.5`

* `model_tuning`          (**Positive float**) Tunable efficiency factor scaling the friction term, default: `1.0`
* `model_reynolds`        (**Positive float**) Estimated Reynolds number, default: `1000000.0`
* `model_friction`        (**String**) Friction factor model, select from `hofer`, `nikuradse`, `altshul`, `schifrinson`, `pmt1025`, `igt`, default: `schifrinson`
* `model_compressibility` (**String**) Compressibility factor model, select from: `ideal`, `dvgw`, `aga88`, `papay`, default: `aga88`
* `model_compref`         (**String**) Reference for compressibility: `steady`, `normal`, default: `steady`
* `model_gravity`         (**String**) Gravity computation: `none`, `static`, `dynamic`, default: `static`

* `steady_maxiter_lin` (**Positive Integer**) Number of least-norm iterations to refine steady-state estimation, default: `20`
* `steady_maxiter_non` (**Positive Integer**) Number of time-step iterations to refine steady-state estimation, default: `1000`
* `steady_maxerror`    (**Positive Float**) Maximal error of refined steady-state, default: `1e-6`
* `steady_Tc`          (**Float**) Critical temperature in Celsius, default: `-82.595`
* `steady_pc`          (**Float**) Critical pressure in Bar, default: `45.988`
* `steady_pn`          (**Float**) Normal pressure in Bar, default: `1.01325`

* `solver_relax`   (**Float in (0,1]**) IMEX solver relaxation, default: `1.0`
* `solver_rk2type` (**Positive Integer**) Number of 2nd order hyperbolic Runge-Kutta stages `5`, `6`, `7`, `8`, `9`, `10`, `11`, `12`, default: `11`
* `solver_rk4type` (**String**) 4th order hyperbolic Runge-Kutta type `MeaR99a`, `MeaR99b`, `TseS05`, default: `MeaR99a`

* `T0_min` (**Float**) Minimum ambient temperature in Celsius, default: `0.0`
* `T0_max` (**Float**) Maximum ambient temperature in Celsius, default: `20.0`
* `Rs_min` (**Float**) Minimum specific gas constant in [J/(kg*K)], default: `500.0`
* `Rs_max` (**Float**) Maximum specific gas constant in [J/(kg*K)], default: `600.0`

* `mor_excitation` (**String**) Generic training input type, select from: `impulse`, `step`, `random-binary`, `white-noise`, default: `step`
* `mor_max`        (**Positive Integer**) Maximum reduced order, default: `200`
* `mor_parametric` (**Boolean**) Use parametric model order reduction, select from `true`, `false`, default: `true`
* `mor_pgrid`      (**Positive Integer**) Sparse parameter grid refinement level, default: `1`

* `eval_pnorm`      (**Float**) Parameter norm: `1`, `2`, `Inf`, default: `2`
* `eval_skip`       (**Positive Integer**) Evaluate every n-th reduced order model, default: `3`
* `eval_max`        (**Positive Integer**) Maximum reduced order to evaluate, default: `200` (use `Inf` for maximum possible)
* `eval_parametric` (**Boolean**) Parametric reduced order model evaluation: `true`, `false`, default: `true`
* `eval_ptest`      (**Positive Integer**) Number of test parameters, default: `5`
* `eval_gain`       (**Boolean**) Use gain correction: `true`, `false`, default: `true`

### Internal Configuration Structure

Internally, the configuration is stored in a structure of structures as follows:

* `config`     (**struct**)
  * `.network` (**struct**) Members: `.dt`, `.vmax`, `.cfl`
  * `.model`   (**struct**) Members: `.tuning`, `.reynolds`, `.friction`, `.gravity`
  * `.steady`  (**struct**) Members: `.dt`, `.maxiter_lin`, `.maxiter_non`, `.maxerror`, `.Tc`, `.pc`, `.pn`, `.compressibility`
  * `.solver`  (**struct**) Members: `.dt`, `.relax`, `.rk2type`, `.rk4type`
  * `.mor`     (**struct**) Members: `.rom_max`, `.parametric`, `.solver`, `.excitation`, `.T0_min`, `.T0_max`, `.Rs_min`, `.Rs_max`, `.pgrid`
  * `.eval`    (**struct**) Members: `.parametric`, `.ptest`, `.T0_min`, `.T0_max`, `.Rs_min`, `.Rs_max`, `.skip`, `.max`, `.pnorm`, `.gain`

### Temperature Units

All input temperatures, i.e., in:

* `morgen.ini` configuration
* `XXXXXX.ini` scenario

and all output temperatures are in **Celsius**.
Internally, all temperatures are in **Kelvin**.

</details>

## Tools

<details><summary markdown="span">(click to expand)</summary>

* `xml2net.xsl`    Converts [gaslib](https://gaslib.zib.de) `.net` XML network definitions into **MORGEN**-compatible `.net` CSV network definitions via XSLTproc:
```
xsltproc -o GasLib-X.csv xml2net.xsl GasLib-X.xml
```
* `csv2net.m`      Converts [SciGRID_Gas](https://gas.scigrid.de) `.csv` CSV network definitions into **MORGEN**-compatible `.net` CSV network definitions:
```
csv2net('X_Y_PipeSegments.csv','myX_Y')
```
* `json2net.m`     Converts [MathEnergy](https://mathenergy.de) `.json` network definitions into **MORGEN**-compatible `.net` CSV network definitions:
```
json2net('X.json','myX')
```
* `vf2kgs.m`       Converts volume flow to kg/s (default gas density is 0.7)
```
vf2kgs(value,vol_unit,time_unit,density)
```
* `psi2bar.m`      Converts psi to bar
```
b = psi2bar(p)
```
* `randscen.m`     Generates a random scenario given a network, implicitly defining training scenario
```
randscen(network,scenario_name)
```
* `cmp_friction.m` Compare friction factors
```
cmp_friction(Re,D,k)
```
* `cmp_compressibility.m` Compare compressibility factors
```
cmp_compressibility(p,T,pc,Tc)
```

</details>

## Notes

Based on numerous numerical experiments we _currently_ recommend the following
model-solver-reductor ensemble(s):

* Model:    `ode_end` (Port-Hamiltonian Endpoint Discretization)
* Solver:   `imex1` (First-Order Implicit-Explicit)
* Reductor: `eds_ro_l` (Structured Linear Empirical Dominant Subspaces)

## Log

* 1.2 (2022-10-07): [doi:10.5281/zenodo.7157808](https://doi.org/10.5281/zenodo.7157808)
  * `ADDED`    Modified POD `mpod` reductor in six variants
  * `ADDED`    configurable number of stages for `rk2hyp` solver
  * `ADDED`    configurable coefficient sets for `rk4hyp` solver
  * `ADDED`    Crank-Nicolson/Adams-Bashforth `cnab2` solver
  * `ADDED`    total elapsed time
  * `ADDED`    MORscore horizontal bar plot
  * `ADDED`    optional argument `cfl`
  * `ADDED`    networks and tests
  * `FIXED`    `randscen` tool
  * `IMPROVED` formulation of model nonlinearities
  * `IMPROVED` model reduction backend `emgr` via 5.99 update
  * `IMPROVED` memory footprint of `rk2hyp` solver
  * `IMPROVED` steady-state extra steps
  * `IMPROVED` plot labels and legends
  * `CHANGED`  reductor full names

* 1.1 (2021-08-08): [doi:10.5281/zenodo.5168949](https://doi.org/10.5281/zenodo.5168949)
  * `ADDED`    optional static gravity term
  * `ADDED`    optional gain correction
  * `ADDED`    explicit RK2 solver `rk2hyp` with increased stability
  * `ADDED`    explicit RK4 solver `rk4hyp` with increased stability
  * `ADDED`    linearized model export pseudo-solver
  * `ADDED`    networks and tests
  * `CHANGED`  nonlinear vector field model-interface
  * `IMPROVED` ROM test logging
  * `IMPROVED` steady state solver stopping criteria
  * `IMPROVED` plot presentation
  * `FIXED`    generic path separators
  * `FIXED`    solver caching
  * `FIXED`    `rk4` solver
  * `FIXED`    compact plot labels

* 1.0 (2021-06-22): [doi:10.5281/zenodo.5012357](https://doi.org/10.5281/zenodo.5012357)
  * `ADDED`    configurable CFL constant
  * `ADDED`    `psi2bar` converter tool
  * `ADDED`    tunable efficiency factor
  * `ADDED`    networks and tests
  * `IMPROVED` steady-state interface
  * `IMPROVED` model-solver interface
  * `IMPROVED` reductor interface
  * `IMPROVED` `rk4` solver
  * `IMPROVED` logging
  * `IMPROVED` `vf2kgs` tool

* 0.99 (2021-04-12): [doi:10.5281/zenodo.4680265](https://doi.org/10.5281/zenodo.4680265)
  * `ADDED`    `gopod_r` reductor
  * `ADDED`    linear reductor variants
  * `ADDED`    SciGRID_gas CSV converter
  * `ADDED`    DEMO code
  * `IMPROVED` model structure

* 0.9 (2020-11-24): [doi:10.5281/zenodo.4288510](https://doi.org/10.5281/zenodo.4288510)
  * Initial release

## References

* C. Himpe, S. Grundel: **System Order Reduction for Gas and Energy Networks**;
  in: Proceedings in Applied Mathematics and Mechanics, 22: e202200201, 2023.
  [doi:10.1002/pamm.202200201](https://doi.org/10.1002/pamm.202200201)
  * See also the references listed herein.

* C. Himpe, S. Grundel, P. Benner: **Next-Gen Gas Network Simulation**;
  in: Progress in Industrial Mathematics at ECMI 2021: 107--113, 2022.
  [doi:10.1007/978-3-031-11818-0_15](https://doi.org/10.1007/978-3-031-11818-0_15)
  * See also the references listed herein.

* C. Himpe, S. Grundel, P. Benner: **Model Order Reduction for Gas and Energy Networks**;
  Journal of Mathematics in Industry 11: 13, 2021.
  [doi:10.1186/s13362-021-00109-4](https://doi.org/10.1186/s13362-021-00109-4)
  * See also the references listed herein.

* P. Benner, S. Grundel, C. Himpe, C. Huck, T. Streubel, C. Tischendorf: **Gas Network Benchmark Models**;
  in: Applications of Differential-Algebraic Equations: Examples and Benchmarks: 171--197, 2019.
  [doi:10.1007/11221_2018_5](https://doi.org/10.1007/11221_2018_5)

* C. Himpe: **Comparing (Empirical-Gramian-Based) Model Order Reduction Algorithms**;
  in: Model Reduction of Complex Dynamical Systems: 141--164, 2021.
  [doi:10.1007/978-3-030-72983-7_7](https://doi.org/10.1007/978-3-030-72983-7_7)

* C. Himpe, S. Grundel, P. Benner: **Efficient Gas Network Simulations**;
  in: German Success Stories in Industrial Mathematics: 17--22, 2022.
  [doi:10.1007/978-3-030-81455-7_4](https://doi.org/10.1007/978-3-030-81455-7_4)

* T. Clees, A. Baldin, P. Benner, S. Grundel, C. Himpe, B. Klaassen, F. Küsters, N. Marheineke,
  L. Nikitina, I. Nikitin, J. Pade, N. Stahl, C. Strohm, C. Tischendorf, A. Wirsen: **MathEnergy – Mathematical Key Technologies for Evolving Energy Grids**;
  in: Mathematical Modeling, Simulation and Optimization for Power Engineering and Management: 233--262, 2021.
  [doi:10.1007/978-3-030-62732-4_11](https://doi.org/10.1007/978-3-030-62732-4_11)

For references see also: [GasMOR](https://www.mpi-magdeburg.mpg.de/4124328/gasmor)

## Roadmap

### 2.0

* [Model]    `ADD` variable supply-demand input-output boundaries
* [Model]    `ADD` scenario valve handling
* [Model]    `ADD` generic compressors as input-output combination
* [Reductor] `ADD` hyper-reductor module (DMD, DEIM, Q-DEIM, Numerical linearization)
* [Octave]   `FIX` slow convergence of `ode23s` in generic solver
* [Octave]   `FIX` incompatibilities in `format_network` (`textscan`)

## Development Guidelines

* The main branch must complete reproducibility (`RUNME_xxx`) system tests successfully **!**
* All source code headers must include: project, version, authors, license, summary **!**
* Understand closures in [Matlab](https://research.wmz.ninja/articles/2017/05/closures-in-matlab.html) **!**
* This project uses [Readme-Driven Development](https://tom.preston-werner.com/2010/08/23/readme-driven-development.html) **!**

## Authors

* Christian Himpe ([orcid:0000-0003-2194-6754](http://orcid.org/0000-0003-2194-6754))
* Sara Grundel ([orcid:0000-0002-0209-6566](http://orcid.org/0000-0002-0209-6566))

## Origin

The `morgen` gas network simulation, testing and benchmarking platform was
developed as part of the [MathEnergy](https://www.mathenergy.de) project.

