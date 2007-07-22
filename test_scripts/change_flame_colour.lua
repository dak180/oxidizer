-- This script reads through the transforms on the first genome
-- and changes the color value to 0.5.
-- The API passes a global table called oxidizer_genomes into Lua and then back into Oxidizer. 


--check for genomes by looking at the size of the table. 
if #oxidizer_genomes == 0 then
	oxidizer_genomes = "This script requires a loaded genome"
	return;
end 

-- lua ipairs start at 1
for i,xform in ipairs(oxidizer_genomes[1].xforms) do
	xform["color"] = 0.5   
end   

-- the results of a script are alway picked up from the global variable oxidizer_genomes
-- we altered that directly so there is no need to anything more.
