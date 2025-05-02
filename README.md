# Overview
Procedurally generated city simulator written in Lua using LÖVE 2D library.

# Table of Contents
  - [How to Use](#how-to-use)
  - [Implementation Details](#implementation-details)
    - [Code Structure](#code-structure)
    - [Procedural Generation](#procedural-generation)
      - [Base Layer](#base-layer)
      - [Zone Layer](#zone-layer)

# How to Use
1. **Clone this repository**
```shell
git clone https://github.com/rm-a0/city-sim
```
2. **Install dependencies** 
- Install Lua 5.4 and LÖVE 11.5 (or compatible versions)
- On Debian-based systems (e.g., Ubuntu)
```shell
sudo apt install lua5.4 love
```
3. **Run simulator**
```shell
love city-sim/src
```

# Implementation Details
## Code structure
```src/
├── core/
│   ├── city.lua             # Contains the City metatable and methods
│   ├── generator.lua        # Encapsulates procedural generation
├── procedural/
│   ├── noise.lua            # Perlin noise generation for terrain features
│   ├── aStar.lua            # A* algorithm for zone connection (Not implementd yet)
│   ├── voronoi.lua          # Voronoi diagram for zoning
│   ├── poisson.lua          # Poisson disk sampling for layout
├── render/
│   ├── draw.lua             # Rendering functions
├── tiles/
│   ├── tileFactory.lua      # Tile creation and logic
│   ├── tile.lua             # Contains the Tile metatable and methods
│   ├── tileTypes/           # Contains different Tile types definitions
├── main.lua
```
## Procedural Generation
The city is generated using several layers of procedural techniques. Each layer adds more detail to the simulation, such as terrain features, zoning, roads, and buildings.

### Base Layer
The first layer is generated using [Perlin Noise](#https://en.wikipedia.org/wiki/Perlin_noise), which is commonly used for generating terrain, such as landscapes or environmental features.

### Zone Layer
Once the base terrain is established, [Voronoi Diagrams](https://en.wikipedia.org/wiki/Voronoi_diagram) are used to generate city zones like residential, commercial, and industrial areas. Seeds are generated using [Poisson Disk Sampling](https://en.wikipedia.org/wiki/Poisson_sampling) for more natural and spaced layout.