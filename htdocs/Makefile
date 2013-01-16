
%.css : %.in
		python /usr/share/pyshared/slimmer/slimmer.py $< css --output=$@

default: planet.css
	@echo "OK"

clean:
	rm *.css || true
