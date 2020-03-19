# Features

## Deferred

        sky - frostbite
        sky - frostbite from spheremap

## Composite/Final

### Composite 0

        GI(RSM-flux) https://pdfs.semanticscholar.org/1b29/71e7024a3e1c4108718e59b5ba4327c44b93.pdf, 
        AO(GTAO) http://iryoku.com/downloads/Practical-Realtime-Strategies-for-Accurate-Indirect-Occlusion.pdf

### Composite 1

shadows

### Composite 2

shading,
         diffuse(burley fitted - <http://www.frostbite.com/wp-content/uploads/2014/11/course_notes_moving_frostbite_to_pbr.pdf> - page 11
                 gotanda - <http://research.tri-ace.com/Data/DesignReflectanceModel_notes.pdf>,
                 oren nayar - <http://blog.selfshadow.com/publications/s2012-shading-course/gotanda/s2012_pbs_beyond_blinn_notes_v3.pdf>
                 Sub Surface - <http://www.iryoku.com/separable-sss/downloads/Separable-Subsurface-Scattering.pdf>

         envMap - cloud approx, sky, rendered ground, if inside turn 0.5
         filtering - AO(GTAO), GI(BILAT)
         color rendered to correct values of radiance
         brdf - https://github.com/wdas/brdf

### Composite 3

    clouds - frostbite
    raytracing - https://casual-effects.blogspot.com/2014/08/screen-space-ray-tracing.html
    brdf - gotanda F - frostbite correlated ggx smith V - ggx D

### Composite 4

filtering pass - Reflections, CLOUDS
generation of bloom and aperature shape
DRAGON's Bloom thanks dethraid.

### Composite 5

Whoop whoop, compile camera aperature iso and exposure.
finalize image with dof

### Final

Get some hot motion blur along with some dank tonemapping
aa - <https://github.com/iryoku/smaa>
