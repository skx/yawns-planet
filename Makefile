#
#  Utility Makefile for people working with Yawns Planet.
#

nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " planet    - Generate the current planet pages."
	@echo " "


clean:
	@find . -name '.*~' -exec rm \{\} \;
	@find . -name '.#*' -exec rm \{\} \;
	@find . -name '*~' -exec rm \{\} \;
	@find . -name '*.bak' -exec rm \{\} \;

planet:
	@./bin/yp

