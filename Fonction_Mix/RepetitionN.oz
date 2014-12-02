declare
local
   RepetitionN
in

%Prend un record répétition(R) comme argument et retourne une liste de vecteurs audios correspondant à la répétit   ion de la musique souhaitée le nombre de fois souhaité.
   %Ce record répétition à la structure suivante : repetition(nombre:⟨naturel⟩ ⟨musique⟩) où "nombre" est le nombre d   'occurences qu'il faut faire de la musique.
   fun {RepetitionN R}
      
	 fun {RepetitionN2 Occ R Acc}

	    if Occ == 0 then Acc
	    else {RepetitionN2 Occ-1 R {Append R.1 Acc}}     %Doit prendre la fonction Mix en argument	    
	    end
	 end  in
      {RepetitionN2 R.nombre R nil}
      
   end

   {Browse {RepetitionN repetition(nombre:5 [1])}}

end
