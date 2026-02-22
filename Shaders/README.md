# VRChat Procedural Shader Pack

This repository now includes three texture-free procedural shaders designed for stylized VRChat worlds and avatars.

## Included shaders

- `ProceduralHologram.shader`
  - Transparent hologram look with scanlines, rim glow, and vertex glitch jitter.
  - Great for sci-fi props, NPC projections, HUD meshes.

- `ProceduralPortalWaves.shader`
  - Circular portal energy pattern with animated rings, spiral phase warping, and fresnel highlights.
  - Works well on discs, planes, and circular meshes.

- `ProceduralLavaTriplanar.shader`
  - Triplanar-mixed volumetric noise for animated lava cracks without UV textures.
  - Useful for rocks, terrain chunks, and molten surfaces.

## VRChat usage notes

- These shaders are written in Unity ShaderLab + CGPROGRAM style for projects using the built-in render pipeline.
- For VRChat (Avatar/World) compatibility, verify your Unity version and shader allowlist constraints.
- Tune emission carefully to avoid over-brightness in VR and to preserve comfort/performance.
