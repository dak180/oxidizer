for i,v in pairs(selected_flame) do print(i,v) end;


for i,v in pairs(selected_flame.background) do print(i,v) end;


for i,v in ipairs(selected_flame.xforms) do 
	print(i,v) 
	for j,k in pairs(v) do 
		print(j,k) 
	end;
end;

return_flame = selected_flame;

for i,v in ipairs(oxidizer_genomes)  do print(i,v) end; 
