-- 
-- A genome is a bunch of nested tables using specific keys. 
-- The top level is a numerically keyed table

new_genomes = {}

new_genome = {
        name = "Oxidizer flame",
        height = 960,
        width = 1280,
        centre_x = 0,
        centre_y = 0,
        scale=163.774,
        quality = 500,
        brightness = 21.5304,
        temporal_samples = 60,
        estimator_radius = 5,
        estimator_curve = 0.6,
        estimator_minimum = 0,
        vibrancy = 1,
        gamma = 2
}

-- there are other ways to set parameters other than when creating the array

new_genome["oversample"]= 2

-- some parameter are tables themseleve

new_genome["background"] = {
            red=0,
            blue=0,
            green=0
}

edit = {
	nick="vargol",
    date="Sat Jul 28 17:32:53 BST 2007",
    comm="Made in Lua for  Oxidizer",
    url="http://oxidizer.sf.net/"
}

new_genome["edit"]=edit
	
-- Note we are only need to set the parameters that do not match the default values.
-- The other parameters we could use are....     
--   
--        passes = 1
--        interpolation = "linear"
--        symmetry = "No Symmetry"
--        filter_shape ="gaussian"
--        filter=1
--        gamma_threshold=0.01
--        hue=0
--        motion_exponent=0
--        time=0
--        contrast=1
--        zoom=0
--        rotate=0


-- There can be more than one xform so they are held in a numerically keyed array

xform = {
                is_finalxform="N",
                color=0,
                weight=0.688159,
                symmetry=0
}


-- the xform co-efficients are a 3x2 2D array , oh yes Lua tables with numeric index start the index at  1

coefs = {}

coefs[1]={
		0.76513,
		0.378207
}
	
coefs[2] = {-0.378207, 0.76513}
coefs[3] = {-0.403473, 0.638495}


xform["coefs"] = coefs

-- here's another way to add things to an 'array' .

variations = {}

variation = {
              name="linear",
              weight=0.746088
}	

table.insert(variations, 1, variation)
table.insert(variations, 2, {name="sinusoidal", weight=0.174912})
table.insert(variations, 3, {name="spherical", weight=-0.563})

xform["variations"] = variations

-- there's also the post co-efficents. They default to the identity matrix but could
-- be populated the same way as the xform co-efficents 
--
--post= {}
--post[1]={1, 0}	
--post[2] = {0, 1}
--post[3] = {0, 0}
--xform["post"] = post

-- and we can now add the xform to the xform array and to the genome.
xforms = {}
xforms[1] = xform

new_genome["xforms"] = xforms

-- final we need to add the colors, we could use a palette 
--
--new_genome["palette"]= 29
--new_genome["hue"]=0.3
--
-- put the use of palettes are depreciated. 
--
-- colours are another numerically indexed tables
-- The colours include there own index from 0 to 255, you can however skip values and oxidizer will interploate / extrapolate the rest


new_genome["colors"] = {
						[1] = {
				            index=0,
				            red=255,
				            blue=0,
				            green=0
						},
						[2] = {
				            index=255,
				            red=0,
				            blue=255,
				            green=0
						}
}


table.insert(new_genomes, 1, new_genome)


status = oxidizer_delegate:renderGenome_toPng(new_genomes, "/Users/vargol/Documents/Oxidizer_Test/lau_render_test.png")
if status ~= 0 then
	print ("ooooops")
	oxidizer_genomes="ooooops"
end 

