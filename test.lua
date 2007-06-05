
print(4);
f=flam3.getFlam3Frame();
print(f.ngenomes);

g=flam3.genome_getitem(f.genomes, 0);
print(g.time);

x=flam3.xform_getitem(g.xform, 0);
print("symmetry" .. x.symmetry);

print(x.c);

t = flam3.getValueFromCoefficient(x.c, 1, 1);
print("c[1][1]" .. t);

t = 0.5;

print(t);

x.symmetry = 16;
g.time = 25;
flam3.setFlam3Frame(f);

