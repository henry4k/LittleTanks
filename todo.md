- Spieler-Klasse
- Wegfindung für KI
- Richtige Tile-Map (Ebene, Berge, Seen, etc.)
- Landschaftsgenerator (love.random)
- Effekte wie z.B. Wolkenschatten, Radspuren, aufgewirbelte Partikelwolken,
  Hülsen


Third-Party-Bibliotheken in einen Third-Part-Ordner verschieben!


## Performance:

Vektoren und AABBs nur nutzen, wenn Daten gespeichert werden.
Bei Funktionsparametern stattdessen eine direkte Übergabe bevorzugen.
(Das gillt insbesondere wenn diese Daten oft geändert werden!)

So viele Sprite-Batches und Atlas-Texturen wie möglich nutzen.


## Brainstorming:


Landschaft:

- Hügel die ein Tile groß sind
- Klippen bzw. Hochebenen
- Felsspalten
- große Steine
- unterschiedlich hohe Berge
  (Es muss aber klar sein, dass die Berge nicht befahren werden können!)
- Seen
  (können nur manche Fahrzeuge überqueren)
- seichte Gewässer
  (manche Fahrzeuge werden verlangsamt)


Generierte stationäre Entities (Strukturen):

- Bäume o.Ä.
    - können zerstört werden
    - spawnen bevorzugt in Wassernähe
- Resourcenpunkte
- Reparaturwerkstatt
    - spawnt bevorzugt in Nähe von Resourcenpunkten oder Banditenlagern
- Händler
    - wie Reparaturwerkstatt, nur können hier auch neü Teile gekauft werden
- Nester
    - spawnen bevorzugt in Nähe von Resourcenpunkten
    - erzeugen Aliens
- Banditenlager
    - spawnen bevorzugt in Nähe von Resourcenpunkten oder Werkstätten
