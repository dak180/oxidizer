
function print_table (table) 

      -- Traverse string keys.  Values are parameters. 
        for k,v in pairs(table) do 
        	 if type(v) == "table" then
        	 	print(k) 
        	 	print_table(v)
        	 else	
        	 	print(k,v) 
        	 end  
        end 
        
        -- Traverse number keys.  Values are subtables. 
        for i,v in ipairs(table) do
        	 if type(v) == "table" then
        	 	print(i) 
        	 	print_table(v)
        	 else	
        	 	print(i,v) 
        	 end  
            
        end   

end


print_table(oxidizer_genomes) 

