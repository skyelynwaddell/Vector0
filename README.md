# ![Map Compile Settings](textures/textures/__TB_empty.png) vector0

First Person Shooter Developed with **Godot 4.3**, **Func Godot,**, **Trenchbroom**, & **FGD**

I figured I would open the code to this FPS I have been developing in Godot 4.3.
Mapping is usually done with trenchbroom or hammer editor using the GameConfig.cfg, and func.fgd properties.
Exporting as .map files will be sufficient, but the engine does support .bsp trees for maps (still work in progress).<br>
Discord: https://discord.gg/ZwwYMr6BDn

All game assets are copyright and NOT valid for redistribution. <br>
The source code, godot project, and any fgd or files (not including game assets) are GPL Licence, you must make available the source code for any modification. https://www.gnu.org/licenses/gpl-3.0.en.html
```
For example, if you distribute copies of such a program, whether gratis or for a fee, you must pass on to the recipients the same freedoms that you received. You must make sure that they, too, receive or can get the source code. And you must show them these terms so they know their rights.
```

# Game Properties

**Preferred File Formats**<br>
**Texture Format:** PNG [.png]\
**Map File Format:** MAP [.map]\
**Audio Format:** OGG [.ogg]\
**Texture Size:** Powers of 2 (Suggested Max 256 x 256)\
**Mapping Suggested Unit Size:** 32 or 64 grid\
**Door Size:** 32w x 96h\
**Vent Size:** 32w x 32h

This engine looks to replicate most features a classic first person shooter would have with all the movement and chonky graphics & textures.
Including the same type of core design principles, techniques, and mapping process as a classic 1990s 3D FPS game.

# Getting Started

The engine is pretty straight forward! \
There is a Godot project called "project.godot" in the root folder of this repo. You can open this in your Godot 4.3 Engine. <a href="https://godotengine.org/download/archive/4.3-stable/">Get Godot 4.3 Stable Release</a>.
```js
WARNING: Opening in older or newer versions of godot may not work, and can corrupt the game project.
``` 

Once in the godot game project the Scene World will contain the level.\
For example you can open up the Level 1 Scene and view all the entities, and objects instantiated by trenchbroom.

In this game we dont directly add objects or items to the game in Godot, this is done through Trenchbroom Level Editor.\
Notice the Build Icon when on the Root of the FuncGodotMap Node, this is the button you will press when you have saved changes to your map in Trenchbroom.

You will need to learn the ins and outs of FuncGodot to make this process easier.
It is also possible to map with the hammer-editor since it also can use FGD files.

# Mapping
<a href="https://trenchbroom.github.io/">Get Trenchbroom Level Editor</a>

To get started with mapping first open up the addons folder inside the Godot Engine FileSystem, and look for `func_godot_local_config.tres`

You will need to update the Trenchbroom Game Config Folder to your trenchbroom Vector0 folder. \
Example: `C:/Users/your_name/Documents/Trenchboom/games/vector0`

You will also need to update your Map Editor Game Path to the path of the Godot Repo you cloned.\
Example: `C:/Users/user_name/Documents/github/Vector0`

Once in Trenchbroom make sure to go into Entity, click Settings and select the custom FGD file located in this repo to get correct Entities.

## Compiling .MAP
When done creating a map in trenchbroom, create a new Godot Scene with a FuncGodotMap Node, and then attach your .map file to the node, and click **"Build".**

## Ignore this step for meow... Compiling BSP (TODO - GET BSP WORKING ~ USING .MAP FOR NOW, SEE ABOVE)
You will need to download Ericwtools, this contains qbsp.exe that we can use with trenchbroom to compile our maps to .BSP<br>
Click Run > Compile Map...
Create a new Profile
Name it Godot or whatever
Make sure it's working directory is: 
```
${MAP_DIR_PATH}
```

Next add a new Run Tool
in the Tool Path, select the qbsp.exe in your ericwtools folder
Add this code to your Parameters field:
```
-nolog -nocolor -nosubdivide ${MAP_BASE_NAME}
```

Make sure Parameters, and Stop on Nonzero Error Code are checked.
When you press compile it will make a bsp of the map now.<br>
You may also need to go in to the Texture Browser, and make sure the textures folder is on the right hand side under Enabled.

## Creating a new Entity


## Creating a Func Brush
You will often see around the map objects prefixed with func, for example func_water.<br>
What is a func? It means functional, and it means that the brush or wall if you will DOES something...
Imagine you could attach a .gdscript script to any brush in trenchbroom, because thats what you can do.

You can transform any kind of brush or wall you create into one of the funcs, for example a DOOR, or a LADDER, WATER, LAVA, etc. You get the idea.

You can right click any brush you have made, and apply a premade function to it from the "func" dropdown once right clicked.

#### Step #1 - Create FGD Definition
To create a new func brush definition, you must first define it in `func.fgd`, see some of the other FUNC defintitions in the FGD to get an idea of how one would be formatted and written.
See <a href="./help/FGD - Valve Developer Community.htm">`FGD FILE FORMAT`</a>

#### Step #2 - Create the script for the brush
Then you will go into Godot game project and define a new func script under `./scripts/func/`.<br>
In this folder contains all the premade functional brush scripts.

If a brush has properties, it will need to be loaded in the editor when the map generates, it doesnt happen in the game.
So any script that has settings being applied from trenchbroom, example a door is open boolean, then you will need to make the script `@tool`!

How do I make my scene/object get the properties from Trenchbroom I defined?
Create a new function exactly like below, except replace the properties with the ones youve defined! <br>
<b>!!! TOOL SCRIPTS WILL ONLY WORK AFTER THE SCRIPT IS SAVED, AND THEN YOU MUST RESTART GODOT. IDK DUDE. !!!</b>
```c
//func brush example script
@tool
var direction : int = 0
var opensize : float = 1.0

func _func_godot_apply_properties(props:Dictionary):
	if "direction" in props: direction = props.direction as int
	if "opensize" in props: opensize = props.opensize as float

func _ready():
    if Engine.is_editor_hint(): return
    // your code here

    pass

func _process(delta):
    if Engine.is_editor_hint(): return
    //your code here

    pass
```


#### Step #3 - Create Resource
You will goto `/entities` folder now and create a new "FuncGodotFGDSolidClass" resource .tres, and then drag this into your fgd.tres entity list (you will see all the other funcs, triggers, and entity .tres filesa in here as well) <br>
Under 'Scripting' you will attach the .gdscript or .cs script you have written to it.
Under FuncGodotFGDEntityClass tab you will add the classname, this would be for example `func_water`, it must match the same name as you named the func brush in `func.fgd`.
<br>
Under 'Node Generation' you can assign what type of node this brush will be
for example<br>
- StaticBody3D
- Area3D
- CharacterBody3D
etc. etc.
<br>
Then in the Name property, also name it the same as the Classname from above.<br>
You can optionally assign which Group this node will get put into as well.

```js
ATTENTION:
NEVER CLICK 'EXPORT' ON THE GODOT FGD BUTTON TAB. THIS WILL OVERWRITE THE FGD, AND ANY NEW ENTITIES YOU JUST ADDED IN THE FGD FILE.
```