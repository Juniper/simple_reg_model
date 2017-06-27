sources = $(wildcard *.txt)

all: $(sources)
	java -jar $(UML_HOME)/plantuml.jar $^ -o images 

clean:
	rm -f images/*.png
