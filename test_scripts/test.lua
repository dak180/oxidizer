
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

print("--- environment ---");
print_table(oxidizer:environmentDictionary(), "") 
print("--- environment ---");

print("--- ss ---");
env = oxidizer:environmentDictionary()
print(env["ss"]);
print("--- ss ---");
--print_table(oxidizer:environmentDictionary(), "") 


print("--- alert --");
if  env["ss"] > 1 then
alert_class=objc:class("NSAlert")
alert_obj = alert_class:alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat("Size Scale is set to " .. env["ss"], "Continue", "Stop", "","")

result = alert_obj:runModal()

print (result)

end
