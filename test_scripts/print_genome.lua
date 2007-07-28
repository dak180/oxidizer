
function print_table (table, old_indent) 

	  local indent = old_indent .. "    "
      -- Traverse string keys.  Values are parameters. 
        for k,v in pairs(table) do 
        	 if type(v) == "table" then
        	 	print(indent .. k) 
        	 	print_table(v, indent)
        	 elseif k ~= "n" then	
        	 		print(indent .. k,v) 
        	 end  
        end 


end


--check for genomes by looking at the size of the table. 
if #oxidizer_genomes == 0 then
	-- as there is one fixed return type we can assign a string to oxidizer_genomes
	-- to return an error message
	oxidizer_genomes = "This script requires a loaded genome"
	return;
end 

print_table(oxidizer_genomes, "") 

