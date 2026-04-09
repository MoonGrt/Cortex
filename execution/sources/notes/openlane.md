---
type: [note]
tags: [EDA, verilator, yosys, openroad]
---

## OpenLane2

This tutorial is based on the [official documentation](https://openlane2.readthedocs.io/en/latest/index.html) and is primarily intended for the Linux - Ubuntu 20.04/22.04 platform. For other platforms, like Windows-WSL / macOS , please refer to the official documentation.

> **Ubuntu 22.04** with **docker** is recommended.

> Install and Operate options: nix or docker

---

### Install & Test

<details>
<summary><strong>nix</strong></summary>

  > Already verified on Ubuntu 20.04 & Ubuntu 22.04

  0. **Prerequisite**

      ```bash
      sudo apt-get update
      sudo apt-get install -y curl git
      ```

  1. **Installing nix**

      ```bash
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --extra-conf "
          extra-substituters = https://openlane.cachix.org
          extra-trusted-public-keys = openlane.cachix.org-1:qqdwh+QMNGmZAuyeQJTH9ErW57OWSvdtuwfBKdS254E="
      ```
      !!! - On Ubuntu, please reopen the terminal !!!

      > Cachix stores Nix build results in the cloud, eliminating the need to rebuild OpenLane dependencies on each machine. Enable binary caching (Cachix) in OpenLane:
      >```bash
      >nix-env -f "<nixpkgs>" -iA cachix
      >sudo env PATH="$PATH" cachix use openlane
      >sudo pkill nix-daemon
      >```

  2. **Clone OpenLane2**

      ```bash
      git clone https://github.com/efabless/openlane2/ ~/openlane2
      cd ~/openlane2
      git submodule update --init --recursive
      ```

  3. **Invoke `nix-shell`**

      ```bash
      nix-shell --pure ~/openlane2/shell.nix
      ```

  4. **Run and verify installation**

      > Run the smoke test to ensure everything is fine. This also automatically downloads PDK and installs to `~/.volare/volare/`.

      ```bash
      openlane --log-level ERROR --condensed --show-progress-bar --smoke-test --pdk gf180mcu
      ```

      > `--pdk <sky130/gf180mcu>`: parameter to select the PDK (default: sky130)
      > Currently, OpenLane2 only supports automatically downloading and installing these two PDKs.

  5. **Exit nix**

      ```bash
      exit
      ```

</details>

<details>
<summary><strong>docker</strong></summary>

> Already verified on Ubuntu 20.04 & Ubuntu 22.04

  0. **Prerequisite**

      > In the new terminal, you can first type `sudo -v` to check your privileges, so you can copy and execute commands in bulk later.

      ```bash
      # Remove old installations
      sudo apt-get remove docker docker-engine docker.io containerd runc
      # Installation of requirements
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl gnupg  lsb-release build-essential \
          python3 python3-venv python3-pip python3-tk make git
      ```

  1. **Installing docker**

      ```bash
      # Add the keyrings of docker
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      # Add the package repository
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      # Update the package repository
      sudo apt-get update
      # Install Docker
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      # Check for installation
      sudo docker run hello-world
      ```

      Making Docker available without root:

      ```bash
      sudo groupadd docker
      sudo usermod -aG docker $USER
      sudo reboot # REBOOT!
      ```
      > Checking without root: `docker run hello-world`

  2. **Checking Installation Requirements**

      ```bash
      docker --version
      python3 --version
      python3 -m pip --version
      ```

      Brand new Ubuntu 20.04 look like this, for reference:
      ```bash
      Docker version 28.1.1, build 4eba377
      Python 3.8.10
      pip 20.0.2 from /usr/lib/python3/dist-packages/pip (python 3.8)
      ```

      Brand new Ubuntu 22.04 look like this, for reference:
      ```bash
      Docker version 29.3.0, build 5927d80
      Python 3.10.12
      pip 22.0.2 from /usr/lib/python3/dist-packages/pip (python 3.10)
      ```

  3. **Install and Test OpenLane2**

      ```bash
      # Download OpenLane using PIP
      python3 -m pip install openlane
      # Run a smoke test to ensure everything is fine.
      # This also automatically downloads PDK and installs to `~/.volare/volare/`.
      python3 -m openlane --dockerized --smoke-test --pdk gf180mcu
      ```

      > `--pdk <sky130/gf180mcu>`: parameter to select the PDK (default: sky130)
      > Currently, OpenLane2 only supports automatically downloading and installing these two PDKs.

  4. **Docker Management**

      TODO:

</details>

---

### Execute Flow

<details>
<summary><strong>nix</strong></summary>

  1. **Invoke `nix-shell`**

      ```bash
      nix-shell --pure ~/openlane2/shell.nix
      ```
      !!! - Make sure you are in `nix-shell`: `[nix-shell:~]$ ` !!!
      > Exit docker: `exit`

  2. **Run & View**

      > demo have already been cloned into `~/openlane2/test/designs`
      > choose `designs/aes` as an example, which is relatively big, might be time consuming (probably half an hour).
      > You can also try `pm32` in offical manual: Getting Started - Newcomers.

      ```bash
      # Run a demo
      openlane ~/openlane2/test/designs/aes/config.json

      # View the layout
      # 1. KLayout
      openlane --last-run --flow openinklayout ~/openlane2/test/designs/aes/config.json
      # 2. OpenROAD
      openlane --last-run --flow openinopenroad ~/openlane2/test/designs/aes/config.json
      ```

      > `openlane` runs `config.json` without `--pdk` -> default: `sky130`

  > Try your own designs!

</details>

<details>
<summary><strong>docker</strong></summary>

    > python3 -m openlane --dockerized \<+args\>
    > You can directly run the commands without invoking docker shell.
    > But, to align with the nix-shell opareations, the docker shell is introduced here.

  0. **Clone demo**
      ```bash
      git clone https://github.com/efabless/openlane2-ci-designs.git
      ```

  1. **Invoke docker shell**

      ```bash
      python3 -m openlane --dockerized
      ```
      !!! - In docker, `~` is not the default user path, `/home/xxx` !!!
      > Recommended: set the $HOME to the user's home directory, like `export HOME=/home/xxx`, right after entering the Docker shell.

  2. **Run & View**

      > choose `designs/aes` as an example, which is relatively big, might be time consuming (probably half an hour).
      > You can also try `pm32` in offical manual: Getting Started - Newcomers.

      ```bash
      # Run a demo
      openlane /home/xxx/openlane2-ci-designs/aes/config.json

      # View the layout
      # 1. KLayout
      openlane --last-run --flow openinklayout /home/xxx/openlane2-ci-designs/aes/config.json
      # 2. OpenROAD
      openlane --last-run --flow openinopenroad /home/xxx/openlane2-ci-designs/aes/config.json
      ```

      > `openlane` runs `config.json` without `--pdk` -> default: `sky130`

  > Try your own designs!

</details>

<br>

**Scripts Flow**

```mermaid
flowchart LR
  A[RTL-Lint] --> B[Synthesis]
  B --> C[Pre-PnR STA]
  C --> D[Floorplan]
  D --> E[Placement]
  E --> F[CTS]
  F --> G[Routing]
  G --> H[RC Extraction]
  H --> I[Post-PnR STA]
  I --> J[DRC/LVS]
  J --> K[GDS Output]
```

1. **RTL Lint**: Check syntax and structural issues.
2. **Synthesis (Yosys)**: RTL → gate-level netlist.
3. **Pre-PnR STA**: Initial timing analysis.
4. **Floorplan**: Define die/core size, macro placement, and PDN.
5. **Placement**: Global + detailed standard cell placement.
6. **CTS (Clock Tree Synthesis)**: Build clock tree, fix skew and hold.
7. **Routing**: Global + detailed routing, antenna fixes.
8. **Post-PnR Analysis**: RC extraction (SPEF) + STA + IR drop report.
9. **Physical Verification**: DRC / LVS / XOR checks.
10. **Tapeout Outputs**: Generate GDS, LEF, netlists, SDF.

---

### Openlane parameters

`openlane --help`

```
[nix-shell:~]$ openlane --help
Usage: openlane [OPTIONS] [CONFIG_FILES] ...

Copy final views:
  --save-views-to DIRECTORY       A directory to copy the final views to, where
                                  each format is saved under a directory named
                                  after the corner ID (much like the 'final'
                                  directory after running a flow.)

Run options: [mutually exclusive]
  --run-tag TEXT                  An optional name to use for this particular
                                  run of an OpenLane-based flow. Used to create
                                  the run directory.
  --last-run                      Use the last run as the run tag.

Other options:
  -j, --jobs INTEGER              The maximum number of threads or processes
                                  that can be used by OpenLane.  [default: 8]
  --design-dir DIRECTORY          The top-level directory for your design that
                                  configuration objects may resolve paths
                                  relative to.
```

---

### Design Analysis

```
openlane projects
└── design
  ├── config.json
  ├── pin.cfg (optional)
  ├── pnr.sdc (optional)
  ├── signoff.sdc (optional)
  └── src
    ├── xxx.v
    └── xxx.v
```

**Design**

1. config.json - OpenLane Configuration File

2. pin.cfg - Pin Configuration File

    > This may affect subsequent static timing analysis, as it could introduce long paths.

3. *.sdc - Synopsys Design Constraints File

    `pnr.sdc` vs `signoff.sdc`

    `pnr.sdc` = guide optimization
    - → Used during placement & routing optimization
    - → Intentionally pessimistic to drive timing closure

    `signoff.sdc` = reflect realitys
    - → Used during final STA (signoff)
    - → More realistic, closer to silicon conditions

    > The PnR constraints file has **more aggressive** constraints than the signoff one, this is done to accommodate the gap between the optimization tool estimation of parasitics and the final extractions on the layout.

    > Possible issues without SDC:
    > Clock definition error → Chip cannot boot
    > Missing false path → Tool over-optimization causing critical path disruption
    > I/O delay deviation → Chip loses connection with the outside world


4. src - Verilog/SystemVerilog/VHDL Sources

**Reports**

<details open>
  <summary>Generated Files</summary>

    COMMANDS: any commands run by the step
    config.json: a configuration file with all variables accessible by this Step
    state_in.json: contains a dictionary of design layout formats (such as DEF files) and design metrics available as inputs to a step
    state_out.json: contains the value state_out.json after updates by the step

    *.log: log files by the step
    *.process_stats.json: statistics about total elapsed time and resource consumption
    *.nl.v: gate-level netlist without power connections
    *.pnl.v: gate-level netlist with power connections
    *.odb: current layout in OpenROAD database format
    *.def: current layout in DEF format
  
    *.sdc: standard delay constraints.
    *.sdf: standard delay format

</details>

**Signoff**

> The flow might be different (the number of steps might be different). Therefore, the step numbers listed in the table below are for reference only. What matters are the step names.

1. drc
    `Magic.DRC`: 62-magic-drc/reports/drc_violations.magic.rpt
    `KLayout.DRC`: 63-klayout-drc/reports/drc_violations.klayout.json
2. LVS
    `Netgen.LVS`: 68-netgen-lvs/reports/lvs.netgen.rpt
3. STA
    `OpenROAD.STAPostPNR`: 54-openroad-stapostpnr/summary.rpt
4. Antenna Check
    `OpenROAD.CheckAntennas`: 45-openroad-checkantennas-1/reports/antenna_summary.rpt

    > There are 2 OpenROAD.CheckAntennas steps. 
    > One after OpenROAD.GlobalRouting 
    > One after OpenROAD.DetailedRouting. 
    > Focus on the second one, as this is the final antenna check.

---

### Violations

> The final parameters runned by openlane is print to `{RUN_TAG}/resolved.json`.

#### `OpenROAD.CheckAntennas`

> The most important results: `Partial/Required` ratios.
> Recommended to fix all antenna violations with ratios higher than 3.

- `config.json`:
  - Increase the number of iterations for antenna repair:
    `"GRT_ANTENNA_ITERS": 10,`
  - Increase the margin for antenna repair:
    `"GRT_ANTENNA_MARGIN": 15,`
  - Enable heuristic diode insertion:
    `"RUN_HEURISTIC_DIODE_INSERTION": true,`
  - Constrain the max wire length (in µm):
    `"DESIGN_REPAIR_MAX_WIRE_LENGTH": 800,`
  - Optimize the global placement for minimum wire length:
    `"PL_WIRE_LENGTH_COEF": 0.05,`

#### `OpenROAD.STAPostPNR`

> Steps:
> 1. According to `summary.rpt`, find the corner with the highest violation count.
> 2. Search `max slew` in the appropriate corner report.

**Max Slew/Cap violations**

- `config.json`:
  - Relax the constraint in PDKs:
    sky130: `"MAX_TRANSITION_CONSTRAINT": 1.5,`
  - Increase the slew/cap repair margins:
    `"DESIGN_REPAIR_MAX_SLEW_PCT": 30,`
    `"DESIGN_REPAIR_MAX_CAP_PCT": 30,`
  - Change the default timing corner:
    `"DEFAULT_CORNER": "max_ss_100C_1v60",`
  - Enable post-global routing design optimizations:
    `"RUN_POST_GRT_DESIGN_REPAIR": true,`
  - Apply design-specific SDC files:
    `"PNR_SDC_FILE": "dir::pnr.sdc",`
    `"SIGNOFF_SDC_FILE": "dir::signoff.sdc",`

> Check long routes: view only prBoundary.boundary, met1.drawing, met2.drawing, and met3.drawing, in KLayout.

**Hold violation**

- `config.json`:
  - Enable post-global routing timing optimizations:
    `"RUN_POST_GRT_RESIZER_TIMING": true,`
  - Increase the hold repair margins:
    `"PL_RESIZER_HOLD_SLACK_MARGIN": 0.2,`
    `"GRT_RESIZER_HOLD_SLACK_MARGIN": 0.2,`
  - Change the default timing corner:
    `"DEFAULT_CORNER": "max_tt_025C_1v80",`
  - Apply design-specific SDC files:
    `"PNR_SDC_FILE": "dir::pnr.sdc",`
    `"SIGNOFF_SDC_FILE": "dir::signoff.sdc",`

#### `Magic.DRC`

#### `KLayout.DRC`

#### `Netgen.LVS`

#### ``

---

### Post-Layout

By default, OpenLane places the automatically downloaded PDK in `~/.volare/volare/`.

> gf180mcu
> sky130

---

### Issue

1. Hold/Setup Worst Slack is extremly high.

    > make sure the "CLOCK_PORT" set in `config.json`, is corressponding to the actual clock port in the design.

2. verilator post-synthesis simulation abnormal.

    Try disable Verilator optimization, by add args `-O0`
    > Slow down the compilation speed.

3. nix-shell cannot find `xdot` command.

    > shell.nix -> flake.nix

    Search `devShells` - There is: `default`, `notebook`, `dev`, `docs`.
    Referencing the `notebook` settings, add `xdot` to the default, like:
    ```nix
    default =
      callPackage (self.createOpenLaneShell {
        extra-packages = (with pkgs; [
          xdot
        ]);
    }) {};
    ```

---

<details>
  <summary>1</summary>
  <blockquote>
    <details>
      <summary>1.1</summary>
      <blockquote>
      </blockquote>
    </details>
    <details>
      <summary>1.2</summary>
      <blockquote>
      </blockquote>
    </details>
  </blockquote>
</details>
