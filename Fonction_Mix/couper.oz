local
   Cut
in

   %Prend un record couper en argument
   %Renvoie le vecteur audio correspondant à la musique coupée dans le record 
   fun {Cut R}
      
      fun {Cut2 Debut Fin L}

	 if Debut < 0.0 then
	    {Map {MakeList {FloatToInt Debut*44100.0}} fun{$ O} O=0.0 end} | {Cut2 0.0 Fin L}
	 elseif Debut > 0.0 then
	    if Debut*44100.0 > {IntToFloat {Length L}} then
	       {Map {MakeList {FloatToInt (Fin - Debut)*44100.0}} fun{$ O} O=0.0 end}
	    else {Cut2 0.0 Fin {List.drop L {FloatToInt Debut*44100.0}}}
	    end
	 else
	    if Fin*44100.0 > {IntToFloat {Length L}} then
	       {Append L {Map {MakeList {FloatToInt (Fin*44100.0-{Length L})}} fun{$ O} O=0.0 end}}
	    elseif Fin*44100.0 < {IntToFloat {Length L}} then
	       {List.take L {FloatToInt ({IntToFloat {Length L}}-Fin*44100.0)}}
	    else L
	    end
	 end	 	 
      end in
      
      {Cut2 R.debut R.fin R.1}  %Remplacer R.1 par fonction Mix de R.1
      
   end
   
   {Browse {Cut couper(debut:0.0001 fin:0.0002 [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19])}} %OK
      
end

   