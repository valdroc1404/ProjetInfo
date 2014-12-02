local
   Cut
in

   %Prend comme argument deux floats :Debut(couper.debut) et Fin(couper.fin) et une liste L de vecteurs audios(couper.1)
   %Renvoie le vecteur audio correspondant à la musique coupée dans le record 
   fun {Cut Debut Fin L}
      
      fun {Cut2 D Debut Fin L L1}

	 if Debut < 0.0 andthen Fin > 0.0 then
	    {Cut2 D 0.0 Fin L {Map {MakeList {FloatToInt (~Debut)*44100.0}} fun{$ O} O=0.0 end}}
	 elseif Debut < 0.0 andthen Fin < 0.0 then
	    {Map {MakeList {FloatToInt (Fin-Debut)*44100.0}} fun{$ O} O=0.0 end}
	 elseif Debut < 0.0 andthen Fin == 0.0 then
	    {Map {MakeList {FloatToInt (~Debut)*44100.0}} fun{$ O} O=0.0 end}
	 elseif Debut > 0.0 then
	    if Debut*44100.0 > {IntToFloat {Length L}} then
	       {Map {MakeList {FloatToInt (Fin - Debut)*44100.0}} fun{$ O} O=0.0 end}
	    else {Cut2 D 0.0 Fin L {List.drop L {FloatToInt Debut*44100.0}}}
	    end
	 else
	    if Fin*44100.0 > {IntToFloat {Length L}} then
	       {Append L1 {Map {MakeList {FloatToInt (Fin*44100.0-{IntToFloat {Length L}})}} fun{$ O} O=0.0 end}}
	    elseif Fin*44100.0 < {IntToFloat {Length L}} andthen D*44100.0>0.0 then
	       {List.take L1 {FloatToInt (Fin*44100.0-D*44100.0)}}
	    elseif Fin*44100.0 < {IntToFloat {Length L}} andthen D*44100.0<0.0 then
	       {Append L1 {List.take L {FloatToInt (Fin*44100.0)}}}
	    elseif Fin*44100.0 < {IntToFloat {Length L}} andthen D*44100.0==0.0 then
	        {List.take L {FloatToInt (Fin*44100.0)}}
	    else L1
	    end
	 end	 
      end in
      
      {Cut2 Debut Debut Fin L nil} 
      
   end
   
   
   {Browse {Cut 0.0 0.0 [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19]}} %OK
      
end


