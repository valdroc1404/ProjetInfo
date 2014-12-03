

% Vous ne pouvez pas utiliser le mot-clé 'declare'.
local Mix Interprete Projet CWD  in
   %CWD contient le chemin complet vers le dossier contenant le fichier 'code.oz'
   CWD = {Property.condGet 'testcwd' '/Users/CedricdeBellefroid/Documents/Universite/Civil/Bac2/Informatique/Projet/ProjetS10/ProjetInfo/'}
   
   % Projet fournit quatre fonctions :
   % {Projet.run Interprete Mix Music 'out.wav'} = ok OR error(...) 
   % {Projet.readFile FileName} = audioVector(AudioVector) OR error(...)
   % {Projet.writeFile FileName AudioVector} = ok OR error(...)
   % {Projet.load 'music_file.oz'} = Oz structure.
   %
   % et une constante :
   % Projet.hz = 44100, la fréquence d'échantilonnage (nombre de données par seconde)
   [Projet] = {Link [CWD#'Projet2014_mozart1.4.ozf']}


   local
      %Audio = {Projet.readFile CWD#'wave/animaux/cow.wav'}
      ToNoteNT
      TableToLine
      IsAList
      IsAList2
      IsTransformation
      IsMultipleTransformation
      ChangeSTransformationInList
      ChangeMTransformationInList
      ModifyInSimpleTransformation
      ChangeMTransformation
      ToNoteT
      TransformationToNote
      ToListeOfEchantillon
      ToEchantillon
      NoteN
      Octave
      ToNote
      Transformation
      FacteurTotalEtirer
      DureeTotalePartition
      TransformationSilence
      ListMultipleTransormation

%%%%%%%%%%%%%%%

      ChooseTypeOfMix
      ToAudioVector
      FromVoixToAudioVectorList
      Clip
      RepetitionN
      FromMusicToVectorAudioTuple
      SumList
      ToIntensity
      TallestList
      SmallestList
      MergeVectorAudio
      Cut
      RepetitionS
      Echo
      DureeVecteurAudio
      EchoRepetition
      SumDecadence
      Fondu
      FonduOption
      L1NonFondu
      L1Fondu
      L2Fondu
      L2NonFondu
      FonduEnchaine
      SuperposeList
      
   in
      
      % Prend la fonction Interprete et une Musique en argument
      % Renvoie le vecteur audio correspondant à la musique 
      fun {Mix Interprete Music}
	 case {Flatten Music} of nil then nil 
	 [] H|T then {Flatten {ChooseTypeOfMix H Interprete} |{Mix Interprete T}}
	 else {ChooseTypeOfMix Music Interprete}
	 end
      end

      % Prend un morceau(Element) et Interprete en argument
      % Renvoie le vecteur audio de cet Element en y appliquant les filtres et transformations demandées
      fun {ChooseTypeOfMix Element Interprete}
	 if {Record.is Element} then
	    if {Record.label Element} == 'voix' then {FromVoixToAudioVectorList {Flatten Element.1}}
	    elseif {Record.label Element} == 'wave' then {Projet.readFile CWD#Element.1}
	    elseif {Record.label Element} == 'merge' then
	       local List = {FromMusicToVectorAudioTuple Element.1 Interprete } in 
		  {MergeVectorAudio List}
	       end
	    elseif {Record.label Element} == 'renverser' then {Reverse {Mix Interprete Element.1}}
	    elseif {Record.label Element} == 'repetition' then
	       if {Value.hasFeature Element nombre} then {RepetitionN Element.nombre {Mix Interprete Element.1}}
	       else {RepetitionS Element.duree {Mix Interprete Element.1}} end
	    elseif {Record.label Element} == 'clip'  then {Clip Element Interprete}
	    elseif {Record.label Element} == 'echo' then
	       if {Value.hasFeature Element repetition} then {Echo Element.1 Element.delai Element.decadence Element.repetition Interprete}
	       elseif {Value.hasFeature Element decadence} then {Echo Element.1 Element.delai Element.decadence nil Interprete}
	       else {Echo Element.1 Element.delai nil nil Interprete} end
	    elseif {Record.label Element} == 'fondu' then {Fondu Element.ouverture Element.fermeture {Mix Interprete Element.1}}
	    elseif {Record.label Element} == 'fondu_enchaine' then {FonduEnchaine Element.duree {Mix Interprete Element.1} {Mix Interprete Element.2}}
	    elseif {Record.label Element} == 'couper' then {Cut Element.debut Element.fin {Mix Interprete Element.1}}
	    else                    
	       local L = {Interprete Element.1} in % l'Element est une partition
	       {FromVoixToAudioVectorList  L} end
	    end 
	 else nil
	 end
      end

      % L = une voix
      % Retourne un vecteur audio 
      fun {FromVoixToAudioVectorList L}
	 if {IsAList L} then
	    case L of H|T andthen (T == nil) == false then 
	       {FonduEnchaine 0.2 {ToAudioVector H}  {FromVoixToAudioVectorList T}}
	    else {ToAudioVector L.1}	 
	    end
	 else
	    {ToAudioVector L} end
      end

      % Prend un échantillon en argument
      % Retourne le vecteur audio correspondant
      fun {ToAudioVector Echantillon}
	 fun {ToAudioVector2 Echantillon Acc Acc2}
	    local F in
	       F =  {Pow 2.0 ({IntToFloat Echantillon.hauteur} / 12.0)}*440.0
	       if Acc < 1.0 then {Fondu 0.1 0.1 Acc2}
	       else	       
		  {ToAudioVector2 Echantillon Acc-1.0  {Sin ((2.0*3.14159*F* Acc)/44100.0)}/2.0|Acc2}   
	       end
	    end
	 end in
	 if {Label Echantillon} == silence then  %Si c'est un silence, vecteur audio rempli de 0
	    {Map {MakeList {FloatToInt Echantillon.duree*44100.0}} fun{$ O} O=0.0 end}	       
	 else {ToAudioVector2 Echantillon {IntToFloat {FloatToInt (Echantillon.duree * 44101.0)}} nil}
	 end
      end


      

      % Prend un filtre "clip" et la fonction Interprete 
      % Renvoie le vecteur audio associé en remplacant les valeurs supérieure(resp. inf) à haut(resp. bas) par haut(resp. bas)
      fun {Clip R Interprete}
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
      
      
      % N = nombre de repetitions, R = vecteur audio à répéter
      % Renvoie le vecteur audio en y ajoutant les vecteurs audios repetés
      fun {RepetitionN N R}
	 fun {RepetitionN2 Occ R Acc}
	    if Occ == 0 then Acc
	    else {RepetitionN2 Occ-1 R {Append R Acc}}    	    
	    end
	 end  in
	 {RepetitionN2 N R nil}
      end

      % S = duree finale des repetitions, R = vecteur audio à répéter
      % Renvoie le vecteur audio en y ajoutant les vecteurs audios repetés entièrement ainsi que la fraction en plus 
      fun {RepetitionS S R}
	 if S > {DureeVecteurAudio R} then
	    {Append {RepetitionN  {FloatToInt (S/{DureeVecteurAudio R})*10.0} div 10 R} {Cut 0.0 (S/{DureeVecteurAudio R}-{IntToFloat {FloatToInt (S/{DureeVecteurAudio R})*10.0} div 10}) * {DureeVecteurAudio R} R}} % Regroupe la liste créée par le nombre entier de fois qu'il doit être répété (utilisation de la fonction RepetitionN) et la liste de la fraction restante (Utilisation de la fonction cut entre 0.0 et le temps restant
	 elseif S == {DureeVecteurAudio R} then R
	 else {Cut 0.0 S R} %Musique tronquée 
	 end
      end

      % R = vecteur audio
      % Renvoie la duree de ce vecteur audio 
      fun {DureeVecteurAudio R}
	 {IntToFloat {Length R}} /44100.0
      end
      
      % L = une liste de tupple intensité(float)#Musique, Interprete est la fonction Interprete
      % Renvoie une liste de tupple intensité(float)#vecteur audio
      fun {FromMusicToVectorAudioTuple L Interprete }
	 fun {FromMusicToVectorAudioTuple2 L Interprete Acc}
	    case L of H|T then 
	       case H of A#B then
		  if Acc == nil then {FromMusicToVectorAudioTuple2 T Interprete [A#{Mix Interprete B}] }
		  else {FromMusicToVectorAudioTuple2 T Interprete {Append Acc [A#{Mix Interprete B}] }} end
	       else {FromMusicToVectorAudioTuple2 T Interprete Acc}
	       end   
	    else
	       case L of A#B then
		  if Acc == nil then [A#{Mix Interprete B}]
		  else {Append Acc [A#{Mix Interprete B}] } end
	       else Acc
	       end  
	    end
	 end in
	 {FromMusicToVectorAudioTuple2 L Interprete nil}  
      end

      % A et B sont des listes de floats et {Length B}>{Length A}
      % Renvoie la liste correspondant à l'addition de ces deux listes
      fun {SumList A B}
	 case A of H|T then
	    (A.1+B.1) | {SumList A.2 B.2}
	 else B
	 end
      end
   

      % Vect = vecteur audio, I = intensité associée
      % Renvoie le vecteur audio combiné de son intensité
      fun{ToIntensity I Vect}
	 {Map Vect fun{$ A} I*A end}
      end
      
      % A et B sont des listes de longueur aléatoire
      % Renvoie la liste la plus longue 
      fun {TallestList A B}
	 if {Length B}>{Length A} then B
	 elseif {Length B}=={Length A} then B
	 else A
	 end
      end

      %A et B sont des listes de longueur aléatoire
      % Renvoie la liste la plus courte
      fun {SmallestList A B}
	 if {Length B}<{Length A} then B
	 elseif {Length B}=={Length A} then A
	 else A
	 end
      end

      % L = liste de tuple regroupant une intensité en float et un vecteur audio ex: 0.5#[0.0 0.2 3.0]
      % Renvoie le vecteur audio correspondant à la fusion des vecteurs audio entré en argument
      fun {MergeVectorAudio L}
	 case L of nil then nil
	 [] H|T then
	    case H of P#Pr then
	       {SumList {SmallestList {ToIntensity P Pr} {MergeVectorAudio T}} {TallestList {ToIntensity P Pr} {MergeVectorAudio T}}}
	    else nil
	    end
	 else
	    case L of P#Pr then
	       {ToIntensity P Pr}
	    else nil
	    end
	 end
      end

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

      % M = musique, Delay = delai de l'echo, Decadence = decadence de l'echo, repetition = nombre de repetition de l'echo
      % Renvoie un vecteur audio en appliquant l'echo demandé à M
      fun {Echo M Delay Decadence Repetition Interprete}
	 if  Repetition == nil andthen Decadence == nil then {Mix Interprete [merge([0.5#M 0.5#[voix(silence(duree:Delay)) M]])]}
	 elseif Repetition == nil  then {Mix Interprete [merge([(1.0/(Decadence+1.0))#M (Decadence/(Decadence+1.0))#[voix(silence(duree:Delay)) M]])]}
	 else {Mix Interprete [merge({EchoRepetition Repetition M Delay Decadence {SumDecadence Repetition Decadence}})]}
	 end
      end

      % Repetition = nombre de repetition, M = musique, Delay = delai, Decadence = decadence, SumDeca = somme des décadence des echos
      % Renvoie une liste de tuple intensité#musique
      fun {EchoRepetition Repetition M Delay Decadence SumDeca}
	 fun {EchoRepetition2 Repetition M Decadence SumDeca DecaAcc DelayAcc Return}  
	    if Repetition > 0 then
	       {EchoRepetition2 Repetition-1 M Decadence SumDeca DecaAcc*Decadence DelayAcc*2.0 (DecaAcc*Decadence/SumDeca)#[voix([silence(duree:DelayAcc)]) M ]|Return}	 
	    else Return
	    end      	 
	 end in
	 {EchoRepetition2 Repetition M Decadence SumDeca 1.0 Delay (1.0/SumDeca)#M}  
      end

      % Repetition = nombre de repetitions, Decadence = decadence entre les echos
      % Renvoie la somme des décadence de chaque echo + 1 (musique de base)
      fun {SumDecadence Repetition Decadence}
	 fun {SumDecadence2 Repetition Acc Decadence}
	    if Repetition > 0 then
	       if Acc == 0.0 then {SumDecadence2 Repetition-1 1.0+Decadence Decadence}
	       else {SumDecadence2 Repetition-1 1.0+Decadence*Acc Decadence}
	       end
	    else
	       if Acc == 0.0 then 1.0 else Acc end
	    end
	 end in
	 {SumDecadence2 Repetition 0.0 Decadence}
      end

      %Prend un Float Duree et deux Listes L1 et L2 en arguments. Duree correspond à la durée du fondu à appliquer, L1 et L2 correspondent a deux vecteurs audios
      %Retourne un vecteur audio correspondant au fondu enchainé des listes L1 et L2 (Les fondus sont superposés)
      fun {FonduEnchaine Duree L1 L2}
	 local A B C in
	    
	    A = {Reverse {FonduOption Duree {Reverse L1}}} %Fondu sur la fin du premier vecteur audio
	    B = {FonduOption Duree L2} %Fondu sur le début du second vecteur audio
	    C = Duree*44100.0 %Nombre d'éléments affectés par le fondu 
	    
	    {Flatten {L1NonFondu C A} | {SuperposeList {L1Fondu C A} {L2Fondu C B}} | {L2NonFondu C B}}	 
	 end
      end


      %Prend deux listes L1 et L2 de mêmes longueurs en argument
      %Retourne la combinaison de ces deux liste (Chaque élément a_i de L1 est sommé avec l'élément b_i de L2)
      fun {SuperposeList L1 L2}
	 fun {SuperposeList2 L1 L2 Acc}
	    case L1 of H|T then 
	       {SuperposeList2 T L2.2 L1.1+L2.1|Acc}
	    else Acc
	    end
	 end in
	 {Reverse {SuperposeList2 L1 L2 nil}}
      end

      %Prend une Float Elem et une liste L1 en argument
      %Retourne L1 à laquelle on à supprimé les Elem derniers éléments
      %Utilisation : Retourne la partie du premier vecteur audio d'un fondu enchainé dont les valeurs ne sont pas modifiées par le fondu
      fun {L1NonFondu Elem L1}
	 {List.take L1 {FloatToInt ({IntToFloat {Length L1}}-Elem)}}
      end
   
      %Prend une Float Elem et une liste L1 en argument
      %Retourne une liste contenant les Elem derniers éléments de L1
      %Utilisation : Retourne la partie du premier vecteur audio d'un fondu enchainé dont les valeurs sont modifiées par le fondu   
      fun {L1Fondu Elem L1}
	 {List.drop L1 {FloatToInt {IntToFloat {Length L1}}-Elem}}
      end

      %Prend une Float Elem et une liste L2 en argument
      %Retourne une liste contenant les Elem premiers éléments de L2
      %Utilisation : Retourne la partie du second vecteur audio d'un fondu enchainé dont les valeurs sont modifiées par le fondu 
      fun {L2Fondu Elem L2}
	 {List.take  L2 {FloatToInt Elem}}
      end

   
      %Prend une Float Elem et une liste L2 en argument
      %Retourne L2 à laquelle on à supprimé les elem premiers éléments
      %Utilisation : Retourne la partie du second vecteur audio d'un fondu enchainé dont les valeurs sont modifiées par le fondu 
      fun {L2NonFondu Elem L2}
	 {List.drop L2 {FloatToInt Elem}}
      end
   

      % Prend deux floats Ouv et Ferm et une liste L en arguments. Ouv et Ferm sont les durées en secondes des ouvertures et fermetures et L est un vecteur audio
      % Retourne le vecteur audio auquel à été appliqué un fondu sur la fermeture et l'ouverture
      % La fonction "Fonduoption" appliquant exactement le fondu recherché pour l'ouverture, nous avons appliqué la même fonction à la liste renversée que nous avons rerenversée par apres
      fun {Fondu Ouv Ferm L}
	 {Reverse {FonduOption Ferm {Reverse {FonduOption Ouv L}}}}
      end

   
      %Prend un float Opt et une Liste L en arguments. Opt est la duree en secondes de l'option (ouverture/fermeture) souhaitée et L est le vecteur audio auquel appliquer le fondu
      %Retourne un vecteur audio correspondant au vecteur audio recu auquel est appliqué le fondu à partir du début de la liste
      fun {FonduOption Opt L}
	 fun {FonduOption2 I L Acc} 
	    if I == 0.0 then Acc
	    else
	       case L of H|T then
		  {FonduOption2 I-1.0 T H*(I/({IntToFloat{FloatToInt (Opt*44100.0)}}+1.0)) | Acc}
	       else
		  L
	       end
	    end	 
	 end in
	 {Append {FonduOption2 {IntToFloat {FloatToInt (Opt*44100.0)}} L nil} {List.drop L {FloatToInt Opt*44100.0}}}
      end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      % Interprete doit interpréter une partition
      fun {Interprete Partition}
	 {ToListeOfEchantillon {TableToLine  {ModifyInSimpleTransformation Partition}}}
      end

      %Transforme un tableau de liste imbriquées en une seule liste en transformant chaque valeur en note(......)
      fun {TableToLine T}
	 case T of P|Pr then 
	    if {IsAList P} then {Append {TableToLine P} {TableToLine Pr} }
	    else
	       {Append [{ToNote P}] {TableToLine Pr} }
	    end
	    
	 else
	    T
	 end
      end


      % Modifie une partition à transformations multiples en une partition à transformations uniques
      % L est une partition
      fun {ModifyInSimpleTransformation L}
	 case L of P|Pr then
	    if {IsMultipleTransformation P}  then {ModifyInSimpleTransformation {Append {ModifyInSimpleTransformation {ChangeMTransformation P}} {ModifyInSimpleTransformation Pr}}}
	    elseif {IsTransformation P}  then {Append {ChangeMTransformation P} {ModifyInSimpleTransformation Pr}}
	    else  {Append [{ModifyInSimpleTransformation P}] {ModifyInSimpleTransformation Pr}} end
	 else
	    if {IsMultipleTransformation L} then {ModifyInSimpleTransformation {ChangeMTransformation L}}
	    else
	       L
	    end
	 end
      end



      %Retourne true si une seule note est transformée, false sinon
      %Les notes peuvent être transformées par plusieurs transformation
      fun {IsMultipleTransformation T}
	 if T == nil then  false
	 elseif {Atom.is T} then false
	 elseif T == silence then false
	 elseif  {IsTransformation T} andthen {IsAList T} == false andthen {IsAList T.1} == true then true
	 else
	    if  {IsTransformation T.1}  andthen {IsAList T.1} == false then 
	       {IsMultipleTransformation T.1}
	    else
	       false
	    end
	 end
      end

      % Renvoie une liste de notes en y appliquant les transformations adéquates
      % A = transformation ex: etirer(facteur:2.0 reduire( facteur: 3.0 [a b]))
      fun {ChangeMTransformation A}
	 fun {ChangeMTransformation2 A Acc}
	    if  {IsTransformation A} andthen {IsAList A} == false then
	       local T in
		  if {Value.hasFeature A facteur} then T = [{Record.label A} A.facteur]
		  else
		     if {Record.label A} == 'transpose' then T = [{Record.label A} A.demitons]
		     elseif {Record.label A} == 'duree' then T = [{Record.label A} A.secondes]
			elseif {Record.label A} == 'muet' then T = [{Record.label A} nil]
		     else T = [{Record.label A} A.note]	   end
		  end
		  {ChangeMTransformation2 A.1 T|Acc}
	       end
	    else
		  case A of P|Pr then
		     {ChangeMTransformationInList Acc A}
		  else
		     {ChangeMTransformationInList Acc [A]}
		  end
	    end
	 end in
	 {ChangeMTransformation2 A nil}
      end

      % Renvoie une liste des notes A en y appliquant les transformation T dans l'ordre de T.1 est la première à appliquer
      % T = liste de transformation sous la forme [[type1 facteur1] [type2 facteur2]]
      % A = liste de notes
      fun {ChangeMTransformationInList T A}
	 case T of P|Pr then
	    local X = {ChangeSTransformationInList P A} in
	       {ChangeMTransformationInList Pr X}
	    end
	 else
	    if T == nil then A
	    else
	       {ChangeSTransformationInList T A}
	    end
	 end
      end


      % Renvoie une liste de A en y appliquant la trasformation T
      %Si T est une durée, la fonction va calculer la durée 'partielle' de chaque note en fonction des transformations qui y sont appliquées
      %Si T est un bourdon, cela va renvoyer le nombre de fois la chaine donnée 
      % T = [type facteur]
      % A = liste de notes
      fun {ChangeSTransformationInList T A}
	 
	 fun {ChangeSTransformationInList2 T A Acc D Bool}
	    
	    case A of P|Pr andthen (Pr == nil) == false then
	       local R = {Record.make T.1 [1 facteur]} in
		  if T.1 == 'duree' andthen Bool == true  then
		     R.facteur = D * {FacteurTotalEtirer P}
		  else R.facteur = T.2.1 end
		  R.1 = P
		  if Acc == nil then {ChangeSTransformationInList2 T Pr R D Bool}
		  else
		     case Acc of X|Xr then {ChangeSTransformationInList2 T Pr {Append Acc [R]} D Bool}
		     else {ChangeSTransformationInList2 T Pr {Append [Acc] [R]} D Bool} end
		  end
	       end
	    else
	       local R = {Record.make T.1 [1 facteur]} in
		  if A == nil then Acc
		  else
		     if T.1 == 'duree' andthen Bool == true then
			R.facteur = D * {FacteurTotalEtirer A.1}
		     else R.facteur = T.2.1 end
		     R.1 = A.1
		     case Acc of X|Xr then {Append Acc [R]}
		     else
			if Acc == nil then [R]
			else {Append [Acc] [R]} end
		     end
		  end
	       end
	    end
	 end in
	 local D in
	    if T.1 == 'duree'  andthen {ListMultipleTransormation A} then
	       D = T.2.1/{DureeTotalePartition A}
	       {ChangeSTransformationInList2 T A nil D true}
	    elseif T.1 == 'duree' andthen {IsAList2 A} then
	       D = T.2.1/{DureeTotalePartition A}
	       {ChangeSTransformationInList2 T A nil D true}
	        elseif T.1 == 'duree' then
	       {ChangeSTransformationInList2 T A nil T.2.1 false}  
	    else
	       {ChangeSTransformationInList2 T A nil 1.0 false}
	    end
	 end
      end

      % L = liste de note transformee ou pas
      % Renvoie true si L contient au moins une transformation de plusieurs note
      fun {ListMultipleTransormation L}
	 case L of P|Pr then
	    if {IsMultipleTransformation P} then true
	    else {IsMultipleTransformation Pr}
	    end
	 else
	   {IsMultipleTransformation L}
	 end
      end
      

	 %Renvoie la Durée de chaque note en fonction des transformations qui y sont appliquées
	 %Note = une note sous format 'a' ou 'etirer(etirer(.... a)) attention, pas de liste de notes meme au sein des transformations
      fun {FacteurTotalEtirer Note}
	    fun{FacteurTotalEtirer2 Note Acc}
	       if {IsTransformation Note} then
		  if {Record.label Note} == 'etirer' orelse {Record.label Note} == 'duree' then
		     if {Value.hasFeature Note secondes} then {FacteurTotalEtirer2 Note.1 Acc*Note.secondes}
		     else  {FacteurTotalEtirer2 Note.1 Acc*Note.facteur} end
		  else {FacteurTotalEtirer2 Note.1 Acc}
		  end
	       elseif {IsAList2 Note} then {DureeTotalePartition Note}*Acc
	       else Acc
	       end   
	    end in
	    {FacteurTotalEtirer2 Note 1.0}   
      end

      %Renvoie la duree totale d'une liste de note en faisant appel à la fonction FacteurTotalEtirer pour chacune d'entre elles
      %A = liste de notes
      fun {DureeTotalePartition A}
	    fun {DureeTotalePartition2 A Acc}
	       case A of P|Pr then
		  if P == nil then Acc
		  else {DureeTotalePartition2 Pr Acc+{FacteurTotalEtirer P} } end
	       else
		  Acc
	       end
	    end in
	    {DureeTotalePartition2 A 0.0}
      end



      %Retourne true si L est une liste 
      fun {IsAList L}
	 case L of P|Pr then true
	 else false end
      end

      % Retourne true si L est une liste de plusieurs elements
      fun {IsAList2 L}
	 case L of P|Pr then
	    if Pr == nil then false
	       else true end
	 else false end
      end

      %Retourne true si c'est une transformation, false sinon
      fun {IsTransformation N}
	 case N of Nom#Octave then false
	 else
	    if {IsAList N} then false
	     else {Atom.is N} == false andthen (N == silence) == false  end end
      end

      %Transforme une note sous format note(nom: octave: alteration: transformation:)
      %Note = une note ou note transformée
      fun {ToNote Note}
	 if  {IsTransformation Note} then
	     {TransformationToNote Note}
	 else {ToNoteNT Note}
	 end
      end
      
      %Transforme une note non transformée sous format note(nom: octave: alteration: transformation:none)
      %Note = une note non transformée
      fun {ToNoteNT Note}
	    case Note of Nom#Octave then note(nom:Nom octave:Octave alteration:'#' transformation:none)
	    [] Atom then
	       case {AtomToString Atom} of [N] then note(nom:Atom octave:4 alteration:none transformation:none)
	       [] [N O] then note(nom:{StringToAtom [N]}octave:{StringToInt [O]} alteration:none transformation:none)
	       else 
		  note(nom:silence octave:none alteration:none transformation:none)
	       end
	    else note(nom:silence octave:none alteration:none transformation:none)
	    end
      end

      %Transforme une note transformée sous format note(nom: octave: alteration: transformation:)
      %T = Note avec transformations
      fun {TransformationToNote T}
	 fun {TransformationToNote2 T Liste}
	    if {IsTransformation T.1} then
	       if Liste == nil then {TransformationToNote2 T.1 [[{Record.label T} T.facteur]]}
	       else {TransformationToNote2 T.1 {Append [[{Record.label T} T.facteur]] Liste}}
	       end
	    else
	       if Liste == nil then {ToNoteT T.1 [[{Record.label T} T.facteur]]}
	       else {ToNoteT T.1 {Append [[{Record.label T} T.facteur]] Liste}}
	       end
	    end
	 end in
	 {TransformationToNote2 T nil}
      end

      %Transforme une note transformée sous format note(nom: octave: alteration: transformation:T)
      %T est une liste de transformations de la première à appliquer à la dernière
      %Note est la note dont les transformation sont T
      fun {ToNoteT Note T}
	 case Note of Nom#Octave then note(nom:Nom octave:Octave alteration:'#' transformation:T)
	    [] Atom then
	       case {AtomToString Atom} of [N] then note(nom:Atom octave:4 alteration:none transformation:T)
	       [] [N O] then note(nom:{StringToAtom [N]}octave:{StringToInt [O]} alteration:none transformation:T)
	       else note(nom:silence octave:none alteration:none transformation:T)
	       end
	 else note(nom:silence octave:none alteration:none transformation:T)
	 end
      end

      % Retourne une liste d'échantillons en fonction d'une liste de notes 
      % Partition = liste de note(.....)
      fun {ToListeOfEchantillon Partition}
	 fun {ToListeOfEchantillon2 Partition Acc}
	    case Partition of P|Pr then
	       if Acc == nil then {ToListeOfEchantillon2 Pr [ {ToEchantillon P}]}
	       else
		  {ToListeOfEchantillon2 Pr {Append Acc [{ToEchantillon P}]}}
	       end
	    else
	       if(Partition == nil) then Acc
	       else
		  {Append Acc [{ToEchantillon Partition}]} end
	    end
	 end in
	 {ToListeOfEchantillon2 Partition nil}
      end

      % Transforme une note sous un format échantillon en y appliquant les transformation adéquates
      % Note = note(nom: octave: alteration: transformation:T)
      fun {ToEchantillon Note}
	 if Note.nom == silence then %local R = {Record.make silence [duree]} in R.duree = 1.0 R end
					{TransformationSilence Note.transformation 1.0}
	  else {Transformation Note.transformation {Octave {NoteN Note.nom } Note.octave Note.alteration} 1.0 none} end
      end

      % Retourne le nombre de demitons qui sépare la note complète de A4
      % Note = nombre demitons qui separe la note en octave 4 de A4
      % Oc = l'octave de la note
      % Alt = 1 si # 0 sinon 
      fun {Octave Note Oc Alt}
	 local A in
	    if Alt == 'none' then A = 0
	    else A = 1 end
	    Note+(Oc-4)*12+A
	 end
      end

      % Applique à une note les différentes transformations qu'elle doit subir et renvoie un échantillon
      % T = liste de transformation [type facteur]
      % H = hauteur de la note par rapport à A4
      % D = durée de la note en fonction
      % In = instrument de la note
      fun {Transformation T H D In}
	 case T of X|Xr then
	    if X == nil then
	       local R = {Record.make echantillon [hauteur duree instrument]}  in
		  R.hauteur = H
		  R.duree = D
		  R.instrument = In
		  R
	       end
	    elseif X.1 == 'etirer' then
	       if X.2.1 == 0.0 then {Transformation Xr H D In}
	       else {Transformation Xr H D*X.2.1 In} end
	    elseif X.1 == 'transpose' then {Transformation Xr H+X.2.1 D In}
	    elseif X.1 == 'duree' then {Transformation Xr H X.2.1 In}
	    elseif X.1 == 'bourdon' then
	       if  X.2.1 == 'silence' then {TransformationSilence [Xr] D}
	       else {Transformation Xr {Octave {NoteN X.2.1.nom } X.2.1.octave X.2.1.alteration} D none} end
	    elseif X.1 == 'muet' then {TransformationSilence Xr D}
	    else {Transformation [Xr] H D In}
	    end
	 else
	    local R = {Record.make echantillon [hauteur duree instrument]}  in
		  R.hauteur = H
		  R.duree = D
		  R.instrument = In
		  R
	    end
	 end
      end

      % Applique à un silence les différentes transformations qu'il doit subir et renvoie un échantillon
      % T = liste de transformation [type facteur]
      % D = Duree du silence
      fun {TransformationSilence T D}
	 case T of X|Xr then
	    if X == nil then
	       local R = {Record.make silence [duree]}  in
		  R.duree = D
		  R
	       end
	    elseif X.1 == 'etirer' then
	       if X.2.1 == 0.0 then {TransformationSilence Xr D}
	       else {TransformationSilence Xr D*X.2.1} end
	    elseif X.1 == 'transpose' then{TransformationSilence Xr D}
	    elseif X.1 == 'duree' then {TransformationSilence Xr X.2.1}
	    elseif X.1 == 'bourdon' then
	       if  X.2.1 == 'silence' then {TransformationSilence [Xr] D}
		  else {Transformation Xr {Octave {NoteN X.2.1.nom } X.2.1.octave X.2.1.alteration} D none} end
	    else {TransformationSilence [Xr] D}
	    end
	 else
	     local R = {Record.make silence [duree]}  in
		  R.duree = D
		  R
	     end
	 end
	 
      end

      
      %Retourne le nombre de demi ton qui separe la note de A4, ne calcule les demitons des notes de l'octave 4
      % Note = a || b || c || d || e || f || g  
      fun {NoteN N}
	 local A4 = 0 in 
	    case N of 'a' then  A4
	    [] 'b' then A4 + 2
	    [] 'c' then A4 + 3
	    [] 'd' then A4 + 5
	    [] 'e' then A4 + 7
	    [] 'f' then A4 + 8
	    else  A4 + 10
	    end
	 end
      end

      
   end




   local 
      Music = {Projet.load CWD#'joie.dj.oz'}
   in
     
    {Browse {Projet.run Mix Interprete Music CWD#'out.wav'}}
      %{Browse {Projet.run Mix Interprete renverser(merge([0.5#wave('wave/animaux/cow.wav') 0.5#wave('wave/animaux/chicken.wav')])) '/Users/CedricdeBellefroid/Documents/Universite/Civil/Bac2/Informatique/Projet/ProjetS10/ProjetInfo/out.wav'}}

      
      
   end
   
end



