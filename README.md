# RHEOL_GUI
[Matlab](https://www.mathworks.com/products/matlab.html)-based [graphical user interface](https://www.mathworks.com/discovery/matlab-gui.html) for constructing strength profiles

To start the GUI, simply type "RHEOL_GUI" in the command window.
The GUI reads a defaul parameter files "Defaul.rhl". It is assumed that all rheology parameter files have extension .rhl

## Description of the GUI
There are several sections to the GUI
### File control
Includes name of available .rhl. Use this section to save work as a new .rhl file.

### Global parameters
Controls the enviroment for the model: gravity, temperature, strain rate, and whether the tectonic regime is extension, compression, or strike-slip faulting. We assume at this point that the strain rate is uniform with depth.

For the temperature, you can use a pre-programmed analytical formula (linear or error function) parameterized with surface temperature, surface geotherm, and asymptotic mantle temperature. It is also possible to read a table of depth - temperature values with the *Custom File* option. It is assumed that the temperature table has extension .thm and that temperature is in Celsius. Two example files (*Default.thm* and *hot.thm*) are provided.

Default parameter values are available for several planets (see *Planet.mat* file). It is possible to modify the temperature characteristcs of the planet but at this point, surface pressure and gravity cannot be edited in the GUI

### Structure
The model contains a stratigraphy with an arbitrary number of layer. The **Structure** drawing summarizes the current structure. 

Each layer in the structure is characterized by 
* A thickness. Changes in thickness are accommodated by pushing material downward.
* An assumption on pore fluid pressure, whether it is hydrostatic or a fraction "lambda" of lithostatic.
* A rock type (at this point, mixtures are not implemented). Each rock type has a unique color in the **Structure** drawing. The density of each rock is taken from the *Rock.mat* file. 

You can add a layer (duplicating the next layer down for initialization) or delete the current layer. 

For each rock included in the layer, you need to select at least one rheology. You can select as many rheologies as you want (hold the control key or command key for multiple selections)
* Brittle strength
  * Byerlee's law
  * Laws for serpentine, also corresponding to a reduced coefficient of friction of 0.25 (Reiner et al., 1994) or a plastic limit of 100 MPa (Amiguet et al., 2014)
  * Laws for ice
* Ductile rheologies
  * A series of strain-rate dependent flow laws. Some have pressure, grain size, and/or water fugacity dependence. Water fugacity is assumed to be at saturation. 
  * If you don't want any ductile rheology, check the box above the list of rheologies.
* Grain size
  * You can select a predefined piezometer
  * By selecting *input*, grain size is fixed to value specified in the input text box.
  
**If you change any parameters, you need to push the button *Changes UNSAVED* at the top of the structure section to record your modifications. When working with several layers, you MUST save each layer before switching to the next one, or the parameters actually used are probably not the ones you intended.**
  
### Actions
Several outputs are defined:
* *Single profile*: Identifies the rheology that predicts the lowest strength at each depth (in practice the structural layer is devided in rheological layers where a single rheology dominates). Plots the strength profile in the **Strength** figure, the emperature (dashed) and grain size (solid) in the **Temperature** figure.
* *Export Model*: save the matlab structure *model* under as matlab binary *root*.mat. *model* is a structure containing information for each structural layers and each rheological sublayer. 
* *Export Single Profile*: prints a PDF figures with the temperature, grain size, and strength profile. The file name is *root*_profile.pdf. The root is specified in the text input window and is the same as the .rhl file per default. 
* *Effective rheology*: Loops over strain rate from 1e-20 to 1e-8 1/s. For each strain rate, the structure is divided in rheological sublayers and the strength is integrated with depth. The effective rheology is defined as the (numerical) relation between strain rate and integrated strength, plotted in the **Strength** figure.
  * After the effective rheology is calculated, you can export it as a figure *root*_rheology.pdf or and ascii table *root*_rheology.rht for use in other applications.
  
## To do list
* Load previously saved model structure, not just .rhl files
* Reinforce command line functionality. If a .rhl file exists, it can be convered into a model structure using *parse_script*. Model structures can be saved as .rhl file using *save_script*. It should be possible to compute strength profiles using *recalc_model*, *calc_profile*, *Define_Layers*, *viz_strength* and/or *RheologyFigureExport* but full functionality is not yet tested. Use [RHEOL](https://github.com/montesi/RHEOL) for a command line approach, including command line interface to construct model. 
* Integrate directly with SCEC CTM. At this point, thermal structure have to be provided as .thm files (simple depth-temperature ASCII table).
* Implement multi-phase mixtures.
* I'm open to suggestions and contributions.

This software was build with support from [Southern Califormia Earthquake Center](https://www.scec.org/) grant 17170 and [National Science Foundation](https://www.nsf.gov/EAR) Grant 1419826.
