local
   Clip
in

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

      {Clip2 R.haut R.bas R.1}  %R.1 doit etre remplacé par la fonction mix qui renvoie une liste de vecteurs
      
   end

   {Browse {Clip clip(bas:~0.5 haut:0.49 [~3.0 10.0 ~1.0 ~0.4 ~0.1 0.0 0.2 0.5 1.0  ~5.0 10.0])}} %OK
end
