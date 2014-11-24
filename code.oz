% Vous ne pouvez pas utiliser le mot-clé 'declare'.
local Mix Interprete Projet CWD in
   % CWD contient le chemin complet vers le dossier contenant le fichier 'code.oz'
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
      Audio = {Projet.readFile CWD#'wave/animaux/cow.wav'}
      ToNote
      TableToLine
      IsAList
      IsTransformation
      IsMultipleTransformation
      ChangeMTransformationInList
      
   in
      % Mix prends une musique et doit retourner un vecteur audio.
      %fun {Mix Interprete Music}
      %   Audio
      %end

      % Interprete doit interpréter une partition
      fun {Interprete Partition}

	 %case {TableToLine Partition} of P|Pr then {ToNote P}|{Interprete Pr}
	 %else
	 %   nil
	 %end


	 case Partition of P|Pr then
	    if {IsMultipleTransformation P} then {Interprete {ChangeMTransformationInList P}}|{Interprete Pr}
	    else {Interprete P}|{Interprete Pr} end
	 else
	    if {IsMultipleTransformation Partition} then {Interprete {ChangeMTransformationInList Partition}}
	    else Partition
	       
	    end
	 end

	 
      end


      %Transforme un tableau de liste imbriquées en une seule liste
      fun {TableToLine T}
	 case T of P|Pr andthen {IsAList P} then {Append {TableToLine P} {TableToLine Pr} }
	 else T
	 end
      end

      %Retourne true si L est une liste 
      fun {IsAList L}
	 case L of P|Pr then true
	 else false end
      end

      %Retourne true si une seule note est transformée, false sinon
      fun {IsMultipleTransformation T}
	 {Atom.is T} == false andthen {IsAList T} == false andthen {IsAList T.1} == true
      end

      %Retourne true si c'est une transformation, false sinon
      fun {IsTransformation N}
	 {Atom.is N} == false  
      end

      %Retourne une liste de transformation 
      fun {ChangeMTransformationInList T}

	 local Result = {NewCell nil} R = {NewCell nil} in
	 
	    for E in T.1 do

	       R := {Record.make  {Record.label  T} [facteur 1]}
	       @R.facteur = T.facteur
	       @R.1 = E
	       if @Result == nil then Result:= @R else
	       Result := @Result|@R end
	    
	    end

	    @Result

	 end
	 
      end
      
      
      %Transforme une note sous format record 
      fun {ToNote Note}

	 if {Atom.is Note} == false then 
	    case Note.1 of Nom#Octave then note(nom:Nom octave:Octave alteration:'#' transformation:{Record.label  Note} facteur:Note.facteur)
	    [] Atom then
	       case {AtomToString Atom} of [N] then note(nom:Atom octave:4 alteration:none transformation:{Record.label  Note} facteur:Note.facteur)
	       [] [N O] then note(nom:{StringToAtom [N]}octave:{StringToInt [O]} alteration:none transformation:{Record.label  Note} facteur:Note.facteur)
	       else nil
	       end
	    else nil
	    end
	    
	 else
	    
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

{Browse {Interprete etirer(facteur:2.0  reduire(facteur:3.0 [c d]))}}
   
end




