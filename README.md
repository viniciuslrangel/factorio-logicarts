# Logistic Carts

POC WIP

**BEHAVIOUR CHANGE for implicit cart stops in 0.1.5 -- detail in change log below**

Small carts (1x1 cars) that follow paths painted on the ground.

* Pathing is not automatic -- networks must designed carefully to avoid collision!
* Simple transport networks require only carts and paint and inserters.
* Complex routing possible via the circuit network and gates.

## Technology

"Logistic Carts" tech (red + green science) is available after researching engines.

## Carts

* Mini 1x1 tile cars
* Base speed 10kph
* Fuel burning
* 10 trunk spaces
* Small equipment grid

As with cars, trunk spaces can be filtered.

Riding in carts is possible, but it's not really practical to drive them. They currently have simple 4-way directional sprites, and their on_tick handler will mess with steering and speed.

## Paint

Cart routing is done by painting paths and symbols on the ground, above ground tiles (concrete, bricks) and below other entities, including belts.

* Green arrows are simply followed
* Yellow arrows mean "turn if clear, else keep going"
* Yellow triangles are a "yield" sign for crossing intersections
* Red octagons are stop points

## Stops

Carts will stop when:

* A path-stop symbol is encountered (see default stop behaviour below)
* A closed gate is encountered on the path

The default stop action is to wait for three seconds of inventory inactivity (similar to the base game train schedule condition).

## Circuit Network

When a cart detects a constant combinator *next to and facing* a stop, it changes the CC signals to show its inventory and equipment contents. It also adds virtual signals:

* C as the cart number (currently entity.unit_number)
* F as the unburnt fuel supply

The cart will check the constant combinator's circuit network for incoming signals too:

* GREEN will make the cart depart the stop
* RED will keep the cart stopped
* L to turn left regardless of path
* R to turn right regardless of path
* S to continue straight regardless of path

In the absense of incoming signals the cart will wait for the default 3s of inactivity.

## Cart Groups

Carts have a small equipment grid, the contents of which is included in the circuit signals sent at constant combinator stops. There are some cheap equipment group markers G1-G5 which can be inserted and used to identify carts via decider combinators. Not quite sure this is the best way forward... but it works for now.

## Carts on Belts

Carts fit perfectly on belts. By laying belts over long stretches of straight path carts will drive at 10kph + belt speed. Think carefully about how they get on and off though: driving onto the side of a belt, or across belts, will probably mess up your network! Also, riding belts around corners will change cart orientation and probably prevent a clean exit.

## UPS

Obviously moving vehicles around with on_tick is a recipe for UPS death. To keep load down the mod does the following:

Uses normal Factorio vehicle behaviour wherever possible. Sets cart speed via entity.speed and reduces friction_modifier. Ignores riding_state and just deducts a little fuel per tile. Does no automatic pathing at all.

Cart speed is a constant 10kph, so on_tick position checks need only run once or twice per tile (about every 43 ticks) while a cart is in motion. Carts waiting at stops or behind other traffic are re-checked only once per second.

Since UPS is dependent on the computer and the base, any UPS reports are welcome (see F5).

## Previous Discussion on similar ideas:

* Monorail https://forums.factorio.com/viewtopic.php?f=33&t=27829
* MiniCarts https://forums.factorio.com/viewtopic.php?f=6&t=53116

Couple other links I can't find right now...

## Change Log

0.1.5

Added an path-stop paint symbol.
*BEHAVIOUR CHANGE*: inserters and constant combinators no longer implicitly stop carts (though gates still do, and a CC next to a stop still sends and receives cart signals). Place explicit path-stop symbols. This change allows carts to supply a row of inserters while driving past, which is an easy way to load balance resource distribution.

0.1.4

Carts will now pause if damaged.
Added L=go-left, R=go-right, S=go-straight incoming signals to direct carts using the circuit network.
Added small equipment grid to carts, and equipment contents is sent to the circuit network at stops.
Added G1-G5 equipment for easily identifying cart groups.

0.1.3

Improve tile clean up when removing from under cars, or when just traversed.
Fix a lua nil reference bug when removing paint path.

0.1.2

Stop leaking state and making save file size blow out. Updating the mod should fix existing saves.

0.1.1

EN locale
