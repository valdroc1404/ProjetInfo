local
   ToFrequency
   ToAudioVector
   IsMorceau
   Clip
   GetDuree
   IsAList
   SumList
   ToIntensity
   TallestList
   SmallestList
   Merge
in

   % Transforme la hauteur H d'un échantillon en la fréquence de son pur          INNUTILE
   % correspondante
   % f = 2(H/12) ∗ 440 [Hz]
   fun {ToFrequency H}  
      {Pow 2.0 ({IntToFloat H.hauteur} / 12.0)}*440.0
   end

    %A et B sont des listes de floats et {Width B}>{Width A}
   %Retourne une liste de floats correspondant à la somme des éléments correspon   dants de chaque liste
   fun {SumList A B}
      case A of H|T then
	 (A.1+B.1) | {SumList A.2 B.2}
      else B
      end
      
   end
   

   %Prend un vecteur audio Vect en argument ainsi qu'une intensité I(float) et r   etourne le vecteur multi    plié par l'intensité audio 
   fun{ToIntensity I Vect}

      {Map Vect fun{$ A} I*A end}

   end

   %A et B sont des listes de longueur aléatoire
   %{TallestList A B} renvoie la liste la plus longue
   fun {TallestList A B}

      if {Width B}>{Width A} then B
      elseif {Width B}=={Width A} then B
      else A
      end

   end

   %A et B sont des listes de longueur aléatoire
   %{TallestList A B} renvoie la liste la plus longue
   fun {SmallestList A B}

      if {Length B}<{Length A} then B
      elseif {Length B}=={Length A} then A
      else A
      end

   end

   fun {Merge L}
      case L of nil then nil
      [] H|T then
	 case H of P#Pr then
	    {SumList {SmallestList {ToIntensity P {Mix Interprete Pr}} {Merge T}} {TallestList {ToIntensity P {Mix Interprete Pr}} {Merge T}}}
	 else nil
	 end
      else
	 case L of P#Pr then
	    {ToIntensity P {Mix Interprete Pr}}
	 else nil
	 end
      end
   end
   
   % Transforme un échantillon en vecteur audio (44100 éléments par seconde) en passant par la fréquence
   % 
   fun {ToAudioVector Echantillon}
      fun {ToAudioVector2 Echantillon Acc}
	 local F Vect in
	    F =  {Pow 2.0 ({IntToFloat Echantillon.hauteur} / 12.0)}*440.0
      
	    if Acc == Echantillon.duree * 44100.0 then Vect
	 
	    else Vect =  {Sin ((2.0*3.14159*F* Acc)/44100.0)}/2.0 | {ToAudioVector2 Echantillon Acc+1.0}
	    end
	 end
      end
      {ToAudioVector2 Echantillon 1.0}
   end

   %Transforme une liste d'échantillons (voix) en une liste de vecteurs audios
   fun {FromVoixToAudioVectorList L}
      local A in
	 case L of H|T then
	    if {IsAList H} then A = {Append {FromVoixToAudioVectorList H} {FromVoixToAudioVectorList T}}
	    else {Append A {ToAudioVector H}}
	    end
	 else {FromVoixToAudioVectorList L}	 
	 end
      end
   end

   fun {IsMorceau X}

      case X of H|T then false
      else true
      end

   end

   %Transforme un morceau en un vecteur audio
   fun {MorceauToAudioVector Morceau}

      if {Label Morceau} == 'voix' then {FromVoixToAudioVectorList Morceau.1}
      elseif {Label Morceau} == 'partition' then {FromVoixToAudioVectorList {Interprete Morceau.1}}
      elseif {Label Morceau} == 'wave' then {Projet.readfile Morceau.1}
      elseif {Label Morceau} == 'renverser' then {Mix Interprete {Reverse Morceau.1}}
      elseif {Label Morceau} == 'repetition' then
	 if {HasFeature Morceau nombre}== true then {RepetitionN Morceau}
	 else %repetiton(duree:float <musique>)         
	 end
      elseif {Label Morceau} == 'clip' then {Clip Morceau}
      elseif {Label Morceau} == 'echo' then
	 if {Width {Label Morceau}} == 2 then %echo avec juste delai
	 elseif {Width {Label Morceau}} == 3 then %echo avec delai et decadence
	 else %echo avec delai, decadence et repetition
	 end
      elseif {Label Morceau} == 'fondu' then %fondu
      elseif {Label Morceau} == 'fondu_enchaine' then %fondu enchainé
      elseif {Label Morceau} == 'couper' then {Cut Morceau}
      else {Merge {Label Morceau}.1}    

      end
   end

   %Prend un record répétition(R) comme argument et retourne une liste de vecteurs audios correspondant à la répétit   ion de la musique souhaitée le nombre de fois souhaité.
   %Ce record répétition à la structure suivante : repetition(nombre:⟨naturel⟩ ⟨musique⟩) où "nombre" est le nombre d   'occurences qu'il faut faire de la musique.
   fun {RepetitionN R}
      
      fun {RepetitionN2 Occ R Acc}

	 if Occ == 0 then Acc
	 else {RepetitionN2 Occ-1 R {Append {Mix Interprete R.1} Acc}}  	    
	 end
	    
      end in
      
      {RepetitionN2 R.nombre R nil}
      
   end

   %Retourne la durée totale d'une musique
   fun {GetDuree Music}
      
   end

   %prend un record Clip comme argument et retourne le vecteur audio de la musique dans le record
   %dont toutes les valeurs sont comprises entre le bas et le haut
   fun {Clip R}

      fun {Clip2 Haut Bas R}

	 case R of nil then nil
	 [] H|T then
	    if H<Bas then Bas | {Clip2 Haut Bas T}
	    elseif H>Haut then Haut | {Clip2 Haut Bas T}
	    else H | {Clip2 Haut Bas T}
	    end
	 end	

      end in

      {Clip2 R.haut R.bas {Mix Interprete R.1}}  %R.1 doit etre remplacé par la fonction mix qui renvoie une liste de vecteurs
      
   end

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
      
      {Cut2 R.debut R.fin {Mix Interprete R.1}} 
      
   end

   fun {Mix Interprete Music}

      case Music of H|T then 

	 if {IsAList H} then {Append {Mix Interprete H} {Mix Interprete T}}
	 else {Append {MorceauToAudioVector H} {Mix Interprete T}}
	 end

      else Music
      end
   end

   %La fonction Merge prend une liste de musiques avec intensités ⟨musiques avec intensités⟩ := ⟨float⟩ # ⟨musique⟩ et les combinener.
   %Pour combiner deux vecteurs audio, il suffit de les additionner
   
   

%   fun{WAVToAudioVector Wav}
%      {Projet.readfile Wav}
%   end

 %{Browse {ToFrequency echantillon(duree:0.5 hauteur:10 instrument:none)}}
 %{Browse {ToAudioVector echantillon(duree:0.5 hauteur:10 instrument:none) }}   %OK
end

