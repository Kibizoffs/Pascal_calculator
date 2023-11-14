COMPILER_OPTIONS=
SOURCES=$(wildcard *.pas)

all: calculator clean

calculator: $(SOURCES)
	fpc $(COMPILER_OPTIONS) calculator.pas

clean:
	rm -f -- *.o
	rm -f -- *.ppu
