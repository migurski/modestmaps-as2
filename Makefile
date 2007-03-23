all: SampleClient1.swf

SampleClient1.swf:
	mtasc -version 8 -header 800:600:31 -main -cp lib -swf SampleClient1.swf SampleClient1.as

clean:
	rm -f SampleClient1.swf
