
local


   %%%%%% Parties de la partition pour la main gauche %%%%%
   Gauche1 = [etirer(facteur:0.5 [etirer(facteur:0.8 a#3) etirer(facteur:1.5 a#3) etirer(facteur:3.9 a#3) etirer(facteur:0.8 g#2) etirer(facteur:1.5 g#2) etirer(facteur:3.9 g#2) ])]
   Gauche2 = [etirer(facteur:0.5 [etirer(facteur:0.8 c#3) etirer(facteur:1.5 c#3) etirer(facteur:3.9 c#3)])]  

   Gauche = repetition(nombre:2 [partition(Gauche1) repetition(nombre:2 partition(Gauche2))])  %%% Partition finale pour la main gauche

   
   %%%%%% Parties de la partition pour la main droite
   A1 = [etirer(facteur:0.5 [etirer(facteur:3.1 [a#4 a#4])])]
   B1 = [etirer(facteur:0.5 etirer(facteur:3.1 [c c]))]
   C1 = [etirer(facteur:0.5 etirer(facteur:3.1 g#3))]  

   %%%%%% Voix 1 de la main droite 
   Droite1 = [partition(muet(etirer(facteur:1.55 a))) partition(A1) partition(B1) repetition(nombre:4 partition(C1)) partition(A1) partition(B1) repetition(nombre:3 partition(C1)) partition(etirer(facteur:1.55 g#3))]

   %%%%%% Voix 2 de la main droite 
   Droite2 = [partition(muet(etirer(facteur:1.55 a))) partition(transpose(demitons:3 A1)) partition(transpose(demitons:3 B1)) repetition(nombre:4 partition(transpose(demitons:5 C1))) partition(transpose(demitons:3 A1)) partition(transpose(demitons:3 B1)) repetition(nombre:3 partition(transpose(demitons:5 C1))) partition(transpose(demitons:5 etirer(facteur:1.55 g#3)))]

   %%%%%% Voix 3 de la main droite 
   Droite3 = [partition(muet(etirer(facteur:1.55 a))) partition(transpose(demitons:3 transpose(demitons:3 A1))) partition(transpose(demitons:8 B1)) repetition(nombre:4 partition(transpose(demitons:9 C1))) partition(transpose(demitons:3 transpose(demitons:3 A1))) partition(transpose(demitons:8 B1)) repetition(nombre:3 partition(transpose(demitons:9 C1))) partition(transpose(demitons:9 etirer(facteur:1.55 g#3)))]

in

   
   %%%%%%%%%%%%%%%%% Partition finale %%%%%%%%%%%%%%%%%
   [merge([0.7#Gauche 0.1#Droite2 0.1#Droite1 0.1#Droite3])]
   
end

