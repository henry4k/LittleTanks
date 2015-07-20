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


## Aufgaben:

1. Performance-Test einbauen (4 Stunden)
    - Viele Entities
    - FPS anzeigen

2. Planung, was Vektoren und AABBs betrifft (2 Stunden)

3. Vektoren und AABBs aus allen performance-kritischen Bereichen entfernen (??? Stunden)
    - insbesondere bei Parameteruebergaben
    - PhysicsWorld
    - Solid-Kram
    - Entity-Kram
    - Tile-Kram
    - AABB statt mit Min/Max mit Position und Half-Width implementieren?
        - Gucken wie oft auf `size` oder Aehnliches zugegriffen wird

4. Ueberall Sprite-Batches nutzen (??? Stunden)
    - fuer Tile-Ebene (bereits fertig)
    - fuer Entity-Ebene (3 Stunden)
    - fuer Partikel-Ebene (gibts noch nicht)
    - fuer GUI-Ebene (bereits fertig)

Dateien:

    main.lua
    debugtools.lua
    littletanks/Camera.lua
    littletanks/EntityManager.lua
    littletanks/gui/Button.lua
    littletanks/gui/Entry.lua
    littletanks/gui/Menu.lua
    littletanks/MovableEntity.lua
    littletanks/SimpleTankChassis.lua
    littletanks/Solid.lua
    littletanks/Tank.lua
    littletanks/TankAI.lua
    littletanks/TankChassis.lua
    littletanks/TexturedFrame.lua
    littletanks/TileMap.lua
    littletanks/TileMapView.lua
    littletanks/LazyTileMapView.lua
