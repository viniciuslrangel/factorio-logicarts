# Logistic Carts

POC WIP

Small carts (1x1 cars) that follow paths painted on the ground.

* Pathing is not automatic -- networks must designed carefully to avoid collision!
* Simple transport networks require only carts and paint and inserters.
* Complex routing possible via the circuit network and gates.

## Technology

"Logistic Carts" tech (red + green science) is available after researching engines.
"Electric Logistic Carts" tech (red + green + blue science) is available after researching electric engines.

## Carts

* Mini 1x1 tile cars
* Base speed 5km/h
* Fuel burning or Electric
* 10 trunk spaces, filterable
* Small equipment grid
* Interact with logistic network chests

Riding in carts as passenger is possible, but driving is blocked because it messes up the on_tick handler.

Electric carts work with solar panels or [induction charging](https://mods.factorio.com/mod/Induction%20Charging).

## Paint

Cart routing is done by painting paths and symbols on the ground, above ground tiles (concrete, bricks) and below other entities, including belts.

* Green arrows are simply followed
* Red octagons are stop points
* Blue arrows are *optional routes* (turn if clear)
* Orange arrows are *alternate routes* (turn if blocked)
* Yellow triangles are a *yield* sign for crossing intersections

## Stops

Carts will stop when:

* A path-stop symbol is encountered (see default stop behaviour below)
* A closed gate is encountered on the path
* A RED signal is received

The default stop action is to wait for three seconds of inventory inactivity (similar to the base game train schedule condition).

## Circuit Network

When a cart detects a constant combinator *next to and facing* a stop, it changes the CC signals to show its inventory and equipment contents. It also adds virtual signals:

* C as the cart number (currently entity.unit_number)
* F as the unburnt fuel supply
* E as the available energy in battery equipment

The cart will check the constant combinator's circuit network for incoming signals too:

* GREEN will make the cart depart the stop
* RED will keep the cart stopped
* L to turn left regardless of path
* R to turn right regardless of path
* S to continue straight regardless of path

In the absense of incoming signals the cart will wait for the default 3s of inactivity.

## Filtered Trunk Slots

Cart inventory signals sent to constant combinators are affected by filters:

* Unfiltered trunk items will be a normal positive count
* Filtered trunk items will be negative counts *if there is a shortfall*, else positive

This allows using a decider combinator to direct carts based on their filter states:

* Loading station: *item < 0* (any filtered cart requiring item)
* Unloading station: *item > 0* or *item > -N* (any cart with item)

## Logistic Chest Interaction

Carts detect logistic chests adjacent to stops and will load/unload with similar rules to logistic robots. The trunk *filtered slots* act like logistic request slots.

* Requester or Buffer chest: supply chest from trunk
* Passive provider chest: load trunk *filtered slots* from chest
* Active provider chest: fill trunk from chest
* Storage chest: passive behaviour, then dump all trunk *unfiltered slots* to chest

Carts will reverse up to chests like little delivery vans. We simulate a built-in loader, with transfer speed eqivalent to a yellow belt multipled by current inserter capacity bonus. A basic cart can manage around 14 items/sec, climbing to 84 items/sec after fully researching inserter capacity bonus.

Wait, why 14? Yellow belts do 13.33 items/sec, but to save UPS stopped carts only update once per second, so you get a free 2/3 of an item :)

## Cart Groups

Carts have a small equipment grid, the contents of which is included in the circuit signals sent at constant combinator stops. There are some cheap equipment group markers G1-G5 which can be inserted and used to identify carts via decider combinators. Not quite sure this is the best way forward... but it works for now.

## Carts on Belts

Carts fit perfectly on belts. By laying belts over long stretches of straight path carts will drive at 5km/h + belt speed. Think carefully about how they get on and off though: driving onto the side of a belt, or across belts, will probably mess up your network! Also, riding belts around corners will change cart orientation and probably prevent a clean exit.

## Only 5km/h? Wtf?

Yep. With the automatic logistic chest interaction (un)loading is relatively fast, so we can save some UPS and reduce queuing at stations by trundling around at a slower speed :-)

Use belts for long straight runs if you must go fast.

Probably going to add speed bonus research eventually.

## UPS

Obviously moving vehicles around with on_tick is a recipe for UPS death. To keep load down the mod does the following:

Uses normal Factorio vehicle behaviour wherever possible. Sets cart speed via entity.speed and reduces friction_modifier. Ignores riding_state and just deducts a little fuel per tile. Does no automatic pathing at all.

Cart speed is a constant 5km/h, so on_tick position checks need only run once or twice per tile (about every 43 ticks) while a cart is in motion. Carts waiting at stops or behind other traffic are re-checked only once per second.

Note that the cheapest cart moving state is being stopped on a long straight belt. That means painting paths under the ends of belts for loading/unloading, but not under the whole length of the belt.

Since UPS is dependent on the computer and the base, any UPS reports are welcome (see F5).

## Previous Discussion on similar ideas:

* Monorail https://forums.factorio.com/viewtopic.php?f=33&t=27829
* MiniCarts https://forums.factorio.com/viewtopic.php?f=6&t=53116

Couple other links I can't find right now...

## Thanks to:

* [Arch666Angel](https://mods.factorio.com/user/Arch666Angel) for graphics! (And some more yet to be released...)

## Change Log

0.1.14

Changed yellow *turn-if-clear* arrows to blue *optional routes* (cosmetic only; same item/entity in saves).
Added orange *alternate route* arrows as the inverse action.

0.1.13

BUGFIX: Yield tiles were broken in 0.1.11.
Avoid double-claiming a cell (duplicating the transient marker entity) when CART_TICK_ARRIVING.

0.1.12

BUGFIX: Fix nil reference on entity rotation.

0.1.11

New cart graphics thanks to [Arch666Angel](https://mods.factorio.com/user/Arch666Angel)
Carts now automatically interact with logistic chests adjacent to stops. See above for docs.
Reduced mod overhead a lot; should be easier on UPS and have less bloat in save files now.
BALANCING: Slight increase to burner cart fuel consumption to represent inefficiency compared to electric.
BALANCING: Reduce base cart speed to 5km/h (leaves room for future cart speed research, and is offset by increased loading speed).
BALANCING: Bump up cart recipe costs.

0.1.10

Prevent nil entity ref crash: https://forums.factorio.com/viewtopic.php?f=190&t=61053#p370623 .
Adjust cart timing slightly to reduce jitter (due to auto centering on a tile before moving to next).
Add missing item-group-name.

0.1.9

Added second-tier electric cart. Usable with solar panels or [induction charging](https://mods.factorio.com/mod/Induction%20Charging).
Adjustment to per-tile cart fuel consumption to better match the advertised 50kW consumption.

0.1.8

Changed precedence of yellow turn paint vs L/R/S signals (previous order essentially made them useless when combined).
Fixed constant combinators not resetting in some layouts after cart departure on L/R signal.

0.1.7

Improved anti-collision and path centering checks.
Fixed constant combinator detection when adjacent to more than one path.
Driving carts is now blocked as it causes too many issues with on_tick. Player will be automatically switched to the passenger seat.
*BEHAVIOUR CHANGE*: If a cart has filtered trunk slots the item count sent to constant combinators will be negative if there is a shortfall. This allows *item < 0* checks for loading stops, and *item >= N* of *item != 0* for unloading stops.

0.1.6

Carts now send signals to constant combinators slightly before arrival to allow circuits time to execute and possibly avoid a cart stopping at all.

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
