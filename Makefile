#
#  Utility Makefile for people working with Yawns Planet.
#

nop:
	@echo "Valid targets are (alphabetically) :"
	@echo " "
	@echo " clean     - Remove bogus files."
	@echo " commit    - Commit changes, after running check."
	@echo " diff      - See local changes"
	@echo " planet    - Generate the current planet pages."
	@echo " test      - Run some basic tests."
	@echo " update    - Update from the source repository."
	@echo " "


clean:
	@find . -name '.*~' -exec rm \{\} \;
	@find . -name '.#*' -exec rm \{\} \;
	@find . -name '*~' -exec rm \{\} \;
	@find . -name '*.bak' -exec rm \{\} \;

commit: test
	hg commit

diff:
	hg diff 2>/dev/null

planet:
	@./yp

test:
	cd tests && make

update:
	hg pull --update
