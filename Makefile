all: griddle.swf

griddle.swf:
	mtasc -cp lib -header 640:480:30 -main -swf griddle.swf griddle.as

clean:
	rm -f griddle.swf
