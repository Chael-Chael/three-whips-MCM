function Obj=Obj_Fun(k,x,y)
  Obj=0;
  for i = 1:241
  deltaf=61440000/256;
  Obj=Obj+(x(1,i)+2*pi*deltaf*(y(i)-1)*k);
  end
end
