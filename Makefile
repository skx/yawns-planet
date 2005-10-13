#
#  Utility Makefile for people working with Yawns Planet.
#

nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " clean     - Remove bogus files."
	@echo " commit    - Commit changes, after running check."
	@echo " diff      - Run a 'cvs diff'."
	@echo " planet    - Generate the current planet pages."
	@echo " test      - Run some basic tests."
	@echo " update    - Update from the CVS repository."
	@echo " "


clean:
	@find . -name '.*~' -exec rm \{\} \;
	@find . -name '.#*' -exec rm \{\} \;
	@find . -name '*~' -exec rm \{\} \;
	@find . -name '*.bak' -exec rm \{\} \;

commit: test
	cvs -z3 commit

diff:
	cvs diff --unified 2>/dev/null

planet:
	@./yp

test:
	cd tests && make

update:
	cvs -z3 update -A -d 2>/dev/null
