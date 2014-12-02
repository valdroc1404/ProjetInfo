

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
      %ToNote
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
      
      
   in
      
      % Mix prends une musique et doit retourner un vecteur audio.
      %fun {Mix Interprete Music}
      %   Audio
      %end

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
      {Browse {Interprete [duree(secondes:2.0  transpose( demitons:2 bourdon(note:note(nom:a octave:4 alteration:none transformation:T) [duree(secondes:2.0 [a#1 b]) etirer(facteur:2.0 silence) ]))) a duree(secondes:2.0 silence)]}}
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
   end
   
end



