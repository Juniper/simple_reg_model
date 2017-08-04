uml_sources = $(wildcard *.txt)

all: uml temp_images/hier_graph.png
	@echo Done building all the images

uml: $(uml_sources)
	java -jar $(UML_HOME)/plantuml.jar $^ -o temp_images 

temp_images/hier_graph.png: hier_graph.gv
	dot -Tpng $< -o $@

clean:
	rm -f temp_images/*.png
