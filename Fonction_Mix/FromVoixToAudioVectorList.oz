
local
   ToAudioVector
   FromVoixToAudioVectorList
in

   % Transforme un échantillon en vecteur audio (44100 éléments par seconde) en passant par la fréquence
   % 
   fun {ToAudioVector Echantillon}
      fun {ToAudioVector2 Echantillon Acc Acc2}
	 local F Vect in
	    F =  {Pow 2.0 ({IntToFloat Echantillon.hauteur} / 12.0)}*440.0
      
	    if Acc < 1.0 then Acc2
	    else	       
		  {ToAudioVector2 Echantillon Acc-1.0  {Sin ((2.0*3.14159*F* Acc)/44100.0)}/2.0|Acc2}   
	    end
	 end
      end in
      if {Label Echantillon} == silence then 
	   {Map {MakeList {FloatToInt Echantillon.duree*44100.0}} fun{$ O} O=0.0 end}	       
      else {ToAudioVector2 Echantillon {IntToFloat {FloatToInt (Echantillon.duree * 44101.0)}} nil}
      end
      
   end


   %Transforme une liste d'échantillons (voix) en un vecteur audio
   fun {FromVoixToAudioVectorList L}
      case L of H|T andthen (T == nil) == false then {Append {ToAudioVector H}  {FromVoixToAudioVectorList T}}
      else {ToAudioVector L.1}	 
      end
   end

   %{Browse {ToAudioVector echantillon(duree:1.0 hauteur:2 instrument:none)}}  %OK
   %{Browse {FromVoixToAudioVectorList [silence(duree:0.0001) echantillon(hauteur:1 duree:1.0) echantillon(hauteur:2 duree:1.0) echantillon(hauteur:3 duree:1.0)]}}  %Compile mais pas de retour
   {Browse {FromVoixToAudioVectorList [silence(duree:0.0001) echantillon(hauteur:1 duree:0.0001) silence(duree:0.0002)]}}
end
