
% Vous ne pouvez pas utiliser le mot-clé 'declare'.
local Mix Interprete Projet CWD in
   %CWD contient le chemin complet vers le dossier contenant le fichier 'code.oz'
   CWD = {Property.condGet 'testcwd' '/Users/CedricdeBellefroid/Documents/Université/Civil/Bac2/Informatique/Projet/Projet2014/'}
   
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
      ToNote
      TableToLine
      IsAList
      IsTransformation
      IsMultipleTransformation
      ChangeSTransformationInList
      ChangeMTransformationInList
      ModifyInSimpleTransformation
      ChangeMTransformation
      
      
   in
      
      % Mix prends une musique et doit retourner un vecteur audio.
      %fun {Mix Interprete Music}
      %   Audio
      %end

      % Interprete doit interpréter une partition
      fun {Interprete Partition}
	 {TableToLine {ModifyInSimpleTransformation Partition}}
      end

      %Transforme un tableau de liste imbriquées en une seule liste
      fun {TableToLine T}
	 case T of P|Pr andthen {IsAList P} then {Append {TableToLine P} {TableToLine Pr} }
	 else T
	 end
      end


      % Modifie une partition à transformations multiples en une partition à transformations uniques
      % L est une partition
      fun{ModifyInSimpleTransformation L}
	 case L of P|Pr then
	    if {IsMultipleTransformation P} then {ModifyInSimpleTransformation {ModifyInSimpleTransformation {ChangeMTransformation P}}|{ModifyInSimpleTransformation Pr}}
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
	 elseif  {IsTransformation T} andthen {IsAList T} == false andthen {IsAList T.1} == true then true
	 else
	    if  {IsTransformation T.1}  andthen {IsAList T.1} == false then 
	       {IsMultipleTransformation T.1}
	    else
	       false
	    end
	 end
      end

      % Renvoie une liste de note en y appliquant les transformation adéquates
      % A = transformation ex: etirer(facteur:2.0 reduire( facteur: 3.0 [a b]))
      fun {ChangeMTransformation A}

	 fun {ChangeMTransformation2 A Acc}
      
	    if  {IsTransformation A} andthen {IsAList A} == false then
	       local T in
		  T = [{Record.label A} A.facteur]
		  {ChangeMTransformation2 A.1 T|Acc}
	       end
	    else
	       {ChangeMTransformationInList Acc A}
	    end
	 end in
   
	 {ChangeMTransformation2 A nil}
      end

      % Renvoie une liste des notes A en y appliquant les transformation T
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
      % T = [type facteur]
      % A = liste de notes
      fun {ChangeSTransformationInList T A}
	 fun {ChangeSTransformationInList2 T A Acc}
	    case A of P|Pr andthen (Pr == nil) == false then
	       local R = {Record.make T.1 [1 facteur]} in
		  R.facteur = T.2.1
		  R.1 = P
		  if Acc == nil then {ChangeSTransformationInList2 T Pr R}
		  else
		     case Acc of X|Xr then {ChangeSTransformationInList2 T Pr {Append Acc [R]}}
		     else {ChangeSTransformationInList2 T Pr {Append [Acc] [R]}} end
		  end
	       end
	    else
	       local R = {Record.make T.1 [1 facteur]} in
		  if A == nil then Acc
		  else
		     R.facteur = T.2.1
		     R.1 = A.1
		     case Acc of X|Xr then {Append Acc [R]}
		     else {Append [Acc] [R]} end
		  end
	       end
	    end
	 end in
	 {ChangeSTransformationInList2 T A nil}
      end



      %Retourne true si L est une liste 
      fun {IsAList L}
	 case L of P|Pr then true
	 else false end
      end

      %Retourne true si c'est une transformation, false sinon
      fun {IsTransformation N}
	 {Atom.is N} == false  
      end
     


      
      %Transforme une note sous format record 
      fun {ToNote Note}
	    
	    case Note of Nom#Octave then note(nom:Nom octave:Octave alteration:'#' transformation:none facteur:none)
	    [] Atom then
	       case {AtomToString Atom} of [N] then note(nom:Atom octave:4 alteration:none transformation:none facteur:none)
	       [] [N O] then note(nom:{StringToAtom [N]}octave:{StringToInt [O]} alteration:none transformation:none facteur:none)
	       else nil
	       end
	    else nil
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

   local T = [a b etirer(facteur:2.0 c)] in 
      {Browse {Interprete [T [etirer(facteur:2.0 reduire( facteur:2.0 [a muet(facteur:2.0 a)])) b] b]}}
      %{Browse {ChangeSTransformationInList [etirer 2.0] [etirer(facteur:2.0 a) etirer(facteur:2.0 a) etirer(facteur:2.0 a) etirer(facteur:2.0 a)]}}
      %{Browse {ChangeMTransformationInList [[reduire 2.0] [etirer 2.0] [etirer 2.0]] [a a b]}}
      %{Browse {ChangeMTransformation etirer(facteur:2.0 etirer(facteur:2.0 reduire( facteur:2.0 [a b]))) }}
   end
   
end



