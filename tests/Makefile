
all:
	-perl -MTest::Harness -e "runtests( glob( '*.t' ) );"

modules: .PHONY
	./modules.sh > modules.t

.PHONY:
	true

clean:
	-rm *~

verbose:
	@cd ..; perl --shuffle --verbose tests/
