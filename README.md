morgen -- Model Order Reduction for Gas and Energy Networks (Version 0.9)
=========================================================================

**morgen** is an open-source MATLAB and OCTAVE test platform to compare models,
solvers, and model reduction methods for gas networks and other network systems,
based on the isothermal Euler equations, against each other.

## Development Guidelines

* NEVER BREAK THE MASTER BRANCH **!**
* Source headers include: project, version, authors, license, summary **!**
* Understand [closures](https://en.wikipedia.org/wiki/Closure_%28computer_programming%29) **!**

## Compatibility

* Mathworks [MATLAB](https://matlab.com) >= 2020b
* GNU [Octave](https://octave.org) >= 6.1 (tested on 6.0.92)

## License

**morgen** is licensed under the [2-Clause-BSD](https://opensource.org/licenses/BSD-2-Clause) license.

## Disclaimer

**morgen** is research software and under development.

## Citation

Please cite the **morgen** platform via its companion paper:

P. Benner, S. Grundel, C. Himpe:
**Moder Order Reduction for Gas and Energy Networks**;
arXiv (math.OC): 2020.

## Getting Started

To try **morgen**:

```
> SETUP         % adds the "tests" folder to the path and lists scripts
> sim_pipeline  % runs a pipeline test code
```

## Usage

The **morgen** platform is called via the `morgen` function:

```
morgen(network_id,scenario_id,model_id,solver_id,reductor_ids,varargin)
```

and has five mandatory arguments:

* `network_id`  (string) The network identifier
* `scenario_id` (string) The scenario identifier
* `model_id`    (string) The model identifier
* `solver_id`   (string) The solver identifier
* `reductor_ids` (cell)  An array of reductor identifiers

as well as additional variable length argument list:

* `varargin`     (cell)  an array of flag identifiers

all of which are described below:

* `dt=X`    - Override requested time step in configuration with X (in seconds)
* `ys=X`    - Force minimum y-scale for error plots with 10^X (default: -16)
* `ord=X`   - Override evaluation order in configuration with X (natural number)
* `notest`  - Do not test the reduced order models
* `compact` - Display plots all in one figure

### Network

A network is described by a (directed) graph, given through an edgelist,
which also specifies its edge type, and their physical dimensions and properties.

#### Network Topology Rules

* A network must have at least one supply node!
* All boundary nodes (supply or demand) must connect by exactly one edge!
    * Short pipes can be inserted to enforce this.
* The edge from a supply node must be directed away from it!
    * Hence: No two supply nodes may be directly connected.
* The edge to a demand node must be directed toward it!

#### Available

All available network datasets are listed with the network's number of

 * internal junction nodes (n0),
 * supply boundary nodes (nS), and
 * demand boundary nodes (nD).

##### Toy

* `diamond`  - Diamond Network  (`n0=8, nS=1, nD=1`)
* `fork1`    - Forked Pipeline  (`n0=12, nS=1, nD=2`)
* `fork2`    - Forked Pipeline  (`n0=12, nS=2, nD=1`)
* `comptest` - Compressor Test  (`n0=1, nS=1, nD=1`)
* `PamBD16`  - Triangle Network (`n0=0, nS=1, nD=2`)

##### Synthetic

* `MORGEN`      - Small Network  (`n0=27, nS=2, nD=4`)
* `AzeJ07`      - Small Network  (`n0=5,  nS=1, nD=2`)
* `GruHKetal13` - Small Network  (`n0=11, nS=1, nD=8`)
* `Kiu94`       - Small Network  (`n0=8, nS=1, nD=14`)
* `GruJHetal14` - Medium Network (`n0=?, nS=4, nD=2`)
* `GasLib11`    - Medium Network (`n0=6, nS=3, nD=3`)
* `GasLib24`    - Medium Network (`n0=14, nS=3, nD=5`)
* `GasLib40`    - Medium Network (`n0=?, nS=3, nD=29`)
* `GasLib135`   - Medium Network (`n0=?, nS=3, nD=45`)

##### Pipelines

* `pipeline` - Pipeline (`n0=0, nS=1, nD=1`)
* `Cha09`    - Pipeline (`n0=0, nS=1, nD=1`)
* `RodS18`   - Tree     (`n0=6, nS=1, nD=4`)
* `Guy67`    - Tree     (`n0=8, nS=1, nD=8`)

##### Realistic

* `DeWS00`     - Belgium (`n0=20, nS=6, nD=9`)
* `GasLib134`  - Greece  (`n0=?, nS=3, nD=45`)
* `GasLib582`  - Germany (`n0=?, nS=31, nD=129`)
* `GasLib4197` - Germany (`n0=?, nS=11, nD=1009`)

#### File Format

A network is encoded in a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) file with the file extension `.net`.
The first line is a comment header with a description of the columns, their meaning, and units. 
Each line below the first holds one edge definition with the columns:

* Edge type (P:pipe, S:shortpipe, C:compressor, V:valve)
* Start node identifier (positive integer)
* End node identifier (positive integer)
* Pipe lengths [m] (positive real)
* Pipe diameters [m] (positive real)
* Pipe height difference [m] (positive real)
* Pipe roughness [m] (positive real)

Thus, the gas network's directed graph is represented as an edge list.
Note, currently only positive integers can be used as start and end identifiers.

### Scenario

A scenario data set describes the boundary values and external inhomogeneties of the gas net.
Transient behaviour of supply and demand functions is represented as step functions in compressed form by only marking changes.
Each network has a training scenario (`training.ini`), which has constant boundary values for reduced order model assembly.

#### File Format

A scenario is encoded in an [INI](https://en.wikipedia.org/wiki/INI_file) file, with the extension `.ini`.
Each line holds a key-value pair, for the following keys:

* `T0` - Average ambient temperature [C]
* `Rs` - Average specific gas constant [J/(kg*K)]
* `tH` - Time horizon [s]
* `vs` - Valve setting [1] (pipe separated list of {0,1}) !TODO
* `cp` - Compressor (output) pressure [bar] (pipe separated list)
* `up` - Supply pressure changes [bar] (pipe separated list of semi-colon separated series)
* `uq` - Demand flow changes [kg/s] (pipe separated list of semi-colon separated series)
* `ut` - Time markers for changes in `up` and `uq` [s]

### Model

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
  - `.nP`     (**scalar**) Number of pressure states
  - `.nQ`     (**scalar**) Number of mass-flux states
  - `.nPorts` (**scalar**) Number of ports
  - `.E`      (**handle**) Mass matrix function handle Epz = E(p,z)
  - `.A`      (**matrix**) System matrix
  - `.B`      (**matrix**) Input matrix (models boundary nodes)
  - `.F`      (**matrix**) Source matrix (models the compressor action)
  - `.C`      (**matrix**) Output matrix (sensors at boundary nodes)
  - `.f`      (**handle**) Nonlinear vector field x = f(xs,x,u,p,z)
  - `.J`      (**handle**) Jacobian x = J(xs,x,u,p,z)

#### Available

* `ode_mid` - ODE model using the mid-point discretization
* `ode_end` - ODE model using the end-point discretization

#### Notes

* The argument `x` in nonlinearity `f` and Jacobian `J` refers to the difference to the steady-state.
  This means the `xs+x` yields the actual state.
* Only the components `E`, `f` and `J` are parametrized.
  Particularly, `A` and `B` do not depend on the parameter p.

### Solver

A solver is a time stepper that simulates a trajectory of a model and a scenario.
The prerequisite steady-state initial value is computed from the scenario's boundary values.

#### Interface

`solution = solver(discrete,scenario,config)`

#### Arguments

* `discrete` (**struct**) Discrete model structure
* `scenario` (**struct**) Scenario structure
* `config`   (**struct**) Configuration structure

#### Returns

* `solution` (**struct**)
  * `t`       (**vector**) Time-steps vector
  * `u`       (**matrix**) Discrete inputs-times-steps trajectory
  * `y`       (**matrix**) Discrete outputs-times-steps trajectory
  * `steady`  (**struct**) Steady-state solution structure
    * `xs`    (**vector**) Steady-state
    * `ys`    (**vector**) Steady-state output
    * `z0`    (**scalar**) Global average compressibility
    * `err`   (**scalar**) Steady-state error
    * `iter1` (**scalar**) Algebraic steady-state iterations
    * `iter2` (**scalar**) Differential steady-state iterations
  * `runtime` (**scalar**) Transient solver runtime

#### Available

* `rk4`     - Fourth-order "classic" explicit Runge-Kutta solver
* `generic` - Second-order implicit adaptive `ode23s` Rosenbrock solver
* `imex1`   - First-order implicit-explicit solver
* `imex2`   - Second-order implicit-explicit Runge-Kutta solver

### Reductors

A reductor computes a reduced order discrete model,
aiming to approximate the input-output (boundary-quantity-of-interest) behavior.

#### Interface

`ROM = reductor(solver,discrete,scenario,config)`

#### Arguments

* `solver`   (**handle**) Solver procedure handle
* `discrete` (**struct**) Discrete model structure
* `scenario` (**struct**) Scenario structure
* `config`   (**struct**) Configuration structure

#### Returns

* `ROM` (handle) Function handle with signature: `discrete = ROM(n)`;
  the `ROM` function assembles a `discrete` model structure of order `n`.

#### Available

These structured reductors approximate pressure and mass-flux components separately:

* `pod_r`   (Structured Proper Orthogonal Decomposition)
* `eds_ro`  (Structured Empirical Dominant Subspaces)
* `eds_wx`  (Structured Empirical Cross-Gramian-Based Dominant Subspaces)
* `eds_wz`  (Structured Empirical Non-Symmetric-Cross-Gramian-Based Dominant Subspaces)
* `bpod_ro` (Structured Empirical Balanced Proper Orthogonal Decomposition)
* `ebt_ro`  (Structured Empirical Balanced Truncation)
* `ebt_wx`  (Structured Empirical Cross-Gramian-Based Balanced Truncation)
* `ebt_wz`  (Structured Empirical Non-Symmetric-Cross-Gramian-Based Balanced Truncation)
* `ebg_ro`  (Structured Empirical Balanced Gains)
* `ebg_wx`  (Structured Empirical Cross-Gramian-Based Balanced Gains)
* `ebg_wz`  (Structured Empirical Non-Symmetric-Cross-Gramian-Based Balanced Gains)
* `dmd_r`   (Structured Dynamic Mode Decomposition Galerkin)

### Loading Reduced Order Models

Reduced order models are saved in the `z_roms` folder.
A reduced order model is saved by storing the projectors and encoding the associated:
network, model, and reductor in the filename as follows:

`network--model--reductor.rom`

To load a reduced order model provide a filename of a saved reduced order model instead of the reductor identifier.

## Configuration

The **morgen** platform assumes a configuration [INI](https://en.wikipedia.org/wiki/INI_file)-file in the base folder named `morgen.ini`,
if not found hard-coded default values are used.

* `morgen_plots` (**String**) Folder to store plots, default: `z_plots`
* `morgen_roms`  (**String**) Folder to store reduced order models, defaut: `z_roms`

* `network_dt`   (**Positive float**) Requested time step width in seconds, default: `30`
* `network_vmax` (**Positive float**) Maximum velocity of gas in meters per second, default: `20`

* `model_reynolds`        (**Positive float**) Estimated Reynolds number, defult: `1000000`
* `model_friction`        (**String**) Friction factor model, select from `hofer`, `nikuradse`, `altshul`, `schifrinson`, `pmt1025`, `igt`, default: `hofer`
* `model_compressibility` (**String**) Compressibility factor model, select from: `ideal`, `dvgw`, `aga88`, `papay`, default: `ideal`
* `model_compref`         (**String**) Reference for compressibility: `steady`, `normal`, default: `steady`

* `steady_maxiter`  (**Positive Integer**) Number of iterations to refine steady-state estimation, default: `1`
* `steady_maxerror` (**Positive Integer**)
* `steady_Tc`       (**Float**) Critical temperature in Celsius, default: `-82.595`
* `steady_pc`       (**Float**) Critical pressure in Bar, default: `45.988`
* `steady_pn`       (**Float**) Normal pressure in Bar, default: `1.01325`

* `solver_relax` (**Positive float <1**) IMEX solver relaxation, default: `1.0`

* `T0_min` (**Float**) Minimum ambient temperature in Celsius, default: `0`
* `T0_max` (**Float**) Maximum ambient temperature in Celsius, default: `25`
* `Rs_min` (**Float**) Minimum specific gas constant in [J/(kg*K)], default: `500.0`
* `Rs_max` (**Float**) Maximum specific gas constant in [J/(kg*K)], default: `1000.0`

* `mor_excitation` (**String**) Generic training input type, select from: `impulse`, `step`, `random-binary`, `white-noise`, default: `step`
* `mor_max`        (**Positive Integer**) Maximum reduced order, default: `100`
* `mor_parametric` (**String**) Use parametric model order reduction, select from `yes`, `no`, default: `yes`
* `mor_pgrid`      (**Positive Integer**) Sparse parameter grid refinement level, default: `1`

* `eval_pnorm`      (**Float**) Parameter norm: `1`, `2`, `Inf`, default: `2`
* `eval_skip`       (**Positive Integer**) Evaluate every n-th reduced order model, default: `3`
* `eval_max`        (**Positive Float**) Maximum reduced order to evaluate, default: `Inf`
* `eval_parametric` (**String**) Parametric reduced order model evaluation: `yes`, `no`, default: `yes`
* `eval_ptest`      (**Positive Integer**) Number of test parameters, default: `5`

## Temperature Units

All input temperatures, i.e. in:

* `morgen.ini` configuration
* `XXXXXX.ini` scenario 

and all output temperatures are in **Celsius**.
Internally, all temperatures are in **Kelvin**.

## Tools

* `xml2csv.xsl`    Converts [gaslib](http://gaslib.zib.de) `.net` XML network definitions into **MORGEN**-compatible `.net` CSV network definitions via XSLTproc
```
xsltproc -o GasLib-X.csv xml2csv.xsl GasLib-X.xml
```
* `json2csv.m`     Converts `.json` network definitions into **MORGEN**-compatible `.net` CSV network definitions
* `mf2vf.m`        Converts m3/h to kg/s 
* `randscen.m`     Generates a random scenario to a training scenario
* `cmp_friction.m` Compare friction factors

## Log

* 0.9 (2020-11-24): [doi:10.5281/zenodo.4288510](https://doi.org/10.5281/zenodo.4288510)
  * Initial release

## Roadmap

### 1.0

* Implement valves as affine linear component
* Fix Octave incompatibilities in `format_network`
* Fix slow `ode23s` in Octave
* Test network **partDE**
* Extend documentation

### 1.1

* TEST network **SciGRID_gas**
* ADD model **port-Hamiltonian ODE**
* ADD reductors

## Authors

* Christian Himpe ([orcid:0000-0003-2194-6754](http://orcid.org/0000-0003-2194-6754))
* Sara Grundel ([orcid:0000-0002-0209-6566](http://orcid.org/0000-0002-0209-6566))

