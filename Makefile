zip:
	@if test -z "$(version)"; then echo "expected version=<x.x.x>"; exit 1; fi
	@if test -z "$(factorio)"; then echo "expected factorio=<path>"; exit 1; fi
	./zip.sh $(version) $(factorio)
