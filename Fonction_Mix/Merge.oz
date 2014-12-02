local
   SumList
   ToIntensity
   TallestList
   SmallestList
   Merge
in

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
	    {SumList {SmallestList {ToIntensity P Pr} {Merge T}} {TallestList {ToIntensity P Pr} {Merge T}}}
	 else nil
	 end
      else
	 case L of P#Pr then
	    {ToIntensity P Pr}
	 else nil
	 end
      end
   end
   
   %{Browse {SumList [1 1 1 1 1] [1 2 3 4 5 6 7 8 9 10]}} %OK
   {Browse {Merge [0.5#[1.0 2.0 3.0 4.0] 2.0#[1.0 1.0 1.0 1.0 1.0]]}} %OK
end
