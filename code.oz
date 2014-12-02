

% Vous ne pouvez pas utiliser le mot-clé 'declare'.
local Mix Interprete Projet CWD  in
   %CWD contient le chemin complet vers le dossier contenant le fichier 'code.oz'
   CWD = {Property.condGet 'testcwd' '/Users/Martin/Documents/Université/2ème_année/Q3/Informatique/ProjetInfo/'}
   
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
      
   in
      
      % Mix prends une musique et doit retourner un vecteur audio.
      fun {Mix Interprete Music}
	 case {Flatten Music} of nil then nil %%%
	 [] H|T then {Flatten {ChooseTypeOfMix H Interprete} |{Mix Interprete T}}
	 else {ChooseTypeOfMix Music Interprete}
	 end
      end


      fun  {ChooseTypeOfMix Element Interprete}

	 if {Record.is Element} then

	    if {Record.label Element} == 'voix' then {FromVoixToAudioVectorList {Flatten Element.1}}
	    elseif {Record.label Element} == 'wave' then 'wave' %% wave
	    elseif {Record.label Element} == 'merge' then
	       local List = {FromMusicToVectorAudioTuple Element.1 Interprete } in 
		  {MergeVectorAudio List}
	       end
	    elseif {Record.label Element} == 'renverser' then {Reverse {Mix Interprete Element.1}}
	    elseif {Record.label Element} == 'repetition' then
	       if {Value.hasFeature Element nombre} then {RepetitionN Element.nombre {Mix Interprete Element.1}}
	       else {RepetitionS Element.duree {Mix Interprete Element.1}} end
	    elseif {Record.label Element} == 'clip'  then {Clip Element}
	    elseif {Record.label Element} == 'echo' then
	       if {Value.hasFeature Element repetition} then {Echo Element.1 Element.delai Element.decadence Element.repetition Interprete}
	       elseif {Value.hasFeature Element decadence} then {Echo Element.1 Element.delai Element.decadence nil Interprete}
	       else {Echo Element.1 Element.delai nil nil Interprete} end
	    elseif {Record.label Element} == 'fondu' then 'fondu'
	    elseif {Record.label Element} == 'fondu_enchainer' then 'fondu_enchainer'%% fondu
	    elseif {Record.label Element} == 'couper' then {Cut Element.debut Element.fin {Mix Interprete Element.1}}
	    else
	       {Browse Element}
	       {FromVoixToAudioVectorList {Flatten {Interprete [Element]}}}
	    end 
	 else nil
	 end
      end


      % Transforme un échantillon en vecteur audio (44100 éléments par seconde) en passant par la fréquence
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
	 if {List.is L} then
	    case L of H|T andthen (T == nil) == false then {Append {ToAudioVector H}  {FromVoixToAudioVectorList T}}
	    else {ToAudioVector L.1}	 
	    end
	 else {ToAudioVector L} end
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
	 
	 {Clip2 R.haut R.bas {Mix 'Interprete' R.1}}  %R.1 doit etre remplacé par la fonction mix qui renvoie une liste de vecteurs
      end
      
      
%Prend un record répétition(R) comme argument et retourne une liste de vecteurs audios correspondant à la répétit   ion de la musique souhaitée le nombre de fois souhaité.
%Ce record répétition à la structure suivante : repetition(nombre:⟨naturel⟩ ⟨musique⟩) où "nombre" est le nombre d   'occurences qu'il faut faire de la musique.
      fun {RepetitionN N R}
	 fun {RepetitionN2 Occ R Acc}
	    if Occ == 0 then Acc
	    else {RepetitionN2 Occ-1 R {Append R Acc}}     %Doit prendre la fonction Mix en argument	    
	    end
	 end  in
	 {RepetitionN2 N R nil}
      end
      
      
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
	 if {Length B}>{Length A} then B
	 elseif {Length B}=={Length A} then B
	 else A
	 end
      end

%A et B sont des listes de longueur aléatoire
%{SmallestList A B} renvoie la liste la plus longue
      fun {SmallestList A B}
	 if {Length B}<{Length A} then B
	 elseif {Length B}=={Length A} then A
	 else A
	 end
      end

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

      fun {RepetitionS S R}
	 if S > {DureeVecteurAudio R} then
	    {Append {RepetitionN  {FloatToInt (S/{DureeVecteurAudio R})*10.0} div 10 R} {Cut 0.0 (S/{DureeVecteurAudio R}-{IntToFloat {FloatToInt (S/{DureeVecteurAudio R})*10.0} div 10}) * {DureeVecteurAudio R} R}}
	 elseif S == {DureeVecteurAudio R} then R
	 else {Cut 0.0 S R} 
	 end
      end

      fun {DureeVecteurAudio R}
	 {IntToFloat {Length R}} /44100.0
      end

      fun {Echo M Delay Decadence Repetition Interprete}
	 if  Repetition == nil andthen Decadence == nil then {Mix Interprete [merge([0.5#M 0.5#[voix(silence(duree:Delay)) M]])]}
	 elseif Repetition == nil  then {Mix Interprete [merge([(1.0/(Decadence+1.0))#M (Decadence/(Decadence+1.0))#[voix(silence(duree:Delay)) M]])]}
	 else {Mix Interprete [merge({EchoRepetition Repetition M Delay Decadence {SumDecadence Repetition Decadence}})]}
	 end
      end

      fun {EchoRepetition Repetition M Delay Decadence SumDeca}
	 fun {EchoRepetition2 Repetition M Decadence SumDeca DecaAcc DelayAcc Return}  
	    if Repetition > 0 then
	       {EchoRepetition2 Repetition-1 M Decadence SumDeca DecaAcc*Decadence DelayAcc*2.0 (DecaAcc*Decadence/SumDeca)#[voix([silence(duree:DelayAcc)]) M ]|Return}	 
	    else Return
	    end      	 
	 end in
	 {EchoRepetition2 Repetition M Decadence SumDeca 1.0 Delay (1.0/SumDeca)#M}  
      end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      % Interprete doit interpréter une partition
      fun {Interprete Partition}
	 {ToListeOfEchantillon {TableToLine {ModifyInSimpleTransformation Partition}}}
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
	    if {IsMultipleTransformation P} then {ModifyInSimpleTransformation {ModifyInSimpleTransformation {ChangeMTransformation P}}|{ModifyInSimpleTransformation Pr}}
	    elseif {IsTransformation P} then {ChangeMTransformation P}|{ModifyInSimpleTransformation Pr}
	    else {ModifyInSimpleTransformation P}|{ModifyInSimpleTransformation Pr} end
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
	 fun {ChangeSTransformationInList2 T A Acc D}
	    case A of P|Pr andthen (Pr == nil) == false then
	       local R = {Record.make T.1 [1 facteur]} in
		  if T.1 == 'duree' then R.facteur = D * {FacteurTotalEtirer P}
		  else R.facteur = T.2.1 end
		  R.1 = P
		  if Acc == nil then {ChangeSTransformationInList2 T Pr R D}
		  else
		     case Acc of X|Xr then {ChangeSTransformationInList2 T Pr {Append Acc [R]} D}
		     else {ChangeSTransformationInList2 T Pr {Append [Acc] [R]} D} end
		  end
	       end
	    else
	       local R = {Record.make T.1 [1 facteur]} in
		  if A == nil then Acc
		  else
		     if T.1 == duree then R.facteur = D * {FacteurTotalEtirer A}
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
	    if T.1 == 'duree' then D = T.2.1/{DureeTotalePartition A}
	       {ChangeSTransformationInList2 T A nil D}
	    else
	       {ChangeSTransformationInList2 T A nil 1.0}
	    end
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
	       else Acc
	       end
	    end in
	    {DureeTotalePartition2 A 0.0}
	 end



      %Retourne true si L est une liste 
      fun {IsAList L}
	 case L of P|Pr then true
	 else false end
      end

      %Retourne true si c'est une transformation, false sinon
      fun {IsTransformation N}
	 case N of Nom#Octave then false
	 else {Atom.is N} == false andthen (N == silence) == false  end
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




   %local 
   %   Music = {Projet.load CWD#'joie.dj.oz'}
   %in
   %   % Votre code DOIT appeler Projet.run UNE SEULE fois.  Lors de cet appel,
   %   % vous devez mixer une musique qui démontre les fonctionalités de votre
   %   % programme.
   %   %
   %   % Si votre code devait ne pas passer nos tests, cet exemple serait le
   %   % seul qui ateste de la validité de votre implémentation.
   %   {Browse {Projet.run Mix Interprete Music CWD#'out.wav'}}
   %end
   
   local T = [a b etirer(facteur:2.0 c)]
   Tune = [b b c d d c b a g g a b]
   End1 = [etirer(facteur:1.5 reduire(facteur:3.0 [a b muet(facteur:4.0 e)])) etirer(facteur:0.5 a) etirer(facteur:2.0 a)]
   End2 = [etirer(facteur:1.5 a) etirer(facteur:0.5 g) etirer(facteur:2.0 g)]
   Interlude = [a a b g a etirer(facteur:0.5 [b c#5])
                    b g a etirer(facteur:0.5 [b c#5])
		b a g a etirer(facteur:2.0 d) ]
   in
      %{Browse {Interprete [Tune End1 Tune End2 Interlude Tune End2]}}
      %{Browse {Interprete [duree(secondes:4.0 [bourdon(note:silence [a b]) a])]}}
      %{Browse {Interprete [duree(secondes:2.0  transpose( demitons:2 bourdon(note:note(nom:a octave:4 alteration:none transformation:T) [duree(secondes:2.0 [a#1 b]) etirer(facteur:2.0 silence) ]))) a duree(secondes:2.0 silence)]}}
      %{Browse {Interprete [muet([a b etirer(facteur:2.0 silence)])]}}
      %{Browse {ChangeSTransformationInList [etirer 2.0] [etirer(facteur:2.0 a) etirer(facteur:2.0 a) etirer(facteur:2.0 a) etirer(facteur:2.0 a)]}}
      %{Browse {ChangeMTransformationInList [[reduire 2.0] [etirer 2.0] [etirer 2.0]] [a a b]}}
      %{Browse {ChangeMTransformation etirer(facteur:2.0 etirer(facteur:2.0 reduire( facteur:2.0 [a b]))) }}
      %{Browse {ToNote etirer(facteur:2.0 reduire( facteur:3.0 jouer(facteur:4.0 b#2)))}}
      %{Browse {TransformationToNote etirer(facteur:2.0 etirer(facteur:3.0 a))}}
      %{Browse {Transformation [[etirer 2.0]] 0 1.0 none}}
      %{Browse {ToFrequency echantillon(duree:0.5 hauteur:10 instrument:none)}}
      %{Browse {Projet.readFile cat.wav}}
      %{Browse {ChangeSTransformationInList [etirer 2.0] [a]}}

      %{Browse {Mix Interprete echo(delai:0.0001 decadence:2.0 repetition:2 [voix(echantillon(hauteur:1 duree:0.0002))])}}

      %{Browse {Mix Interprete [voix(echantillon(hauteur:1 duree:0.0003))]}}

      {Browse {Mix Interprete [voix(echantillon(hauteur:1 duree:0.0003)) a]}}
      
   end
   
end



