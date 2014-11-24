declare
class Note

   attr next prev first last note transformation
      
   meth init(N P T S) next := nil
      first := self
      last := self
      if (P == nil) == false then
	 prev := P
      else
	 prev := nil
      end
      next := S
      note := N
      transformation := T

      {self createSuite}
      
   end
   
   meth getNext($)
      @next
   end

   meth getPrev($)
      @prev
   end

   meth getFirst($)
      @first
   end

   meth getLast($)
      @last
   end

   meth getNote($)
      @note
   end

   meth getTransformation($)
      @transformation
   end

   meth setNext(N)
      next:= N
   end

   meth setPrev(P)
      prev:= P
   end

   meth setFirst(F)
      first := F
   end

   meth setLast(L)
      last:=L
   end
   
   meth setNote(N)
      note := N
   end

   meth addTransformation(T)
      if @transformation == nil then transformation := T
      else transformation :=  T|@transformation end
   end
   
   meth createSuite
      
      case @note of X|Xr then
         if @next == nil then 
	    next := {New Note init(Xr self @transformation nil)}
	    note := X
	    {self createSuite}
	 else
	    if(Xr == nil) == false then
	       local B = @next
	       in
		  next := {New Note init(Xr self @transformation B)}
	       end
	       note := X
	       {self createSuite}
	    else
	       note := X
	       {self createSuite}
	    end
	    
	 end
	 
	 	    
      else
	 if {IsTransformation @note} == false then
	    case @note of Nom#Octave then
	       note:= {ToNote @note}
	    else
	 
	       local R = {Record.make {Record.label @note} [facteur]} in
		  R.facteur = @note.facteur
		  {self addTransformation(R)}
	       end
	       note := @note.1
	       {self createSuite}
	    end

	 else
	    note:= {ToNote @note}
	 end
	 
	 
      end
      
   end
   
   
end

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
      Note
      
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
	 local X C  in

   C = {NewCell nil}

   X = {New Note init(Partition nil nil nil)}
   C := X
   
   for  while:({@C getNext($)} == nil) == false do
      {Browse {@C getNote($)} }
      {Browse {@C getTransformation($)}}
   C := {@C getNext($)}
   end
   
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

{Browse {Interprete etirer(facteur:2.0  reduire(facteur:3.0 [c d]))}}
   
end




