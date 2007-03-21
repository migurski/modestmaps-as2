all: SampleClient.swf

SampleClient.swf:
	mtasc -version 8 -header 800:600:31 -main -cp lib -swf SampleClient.swf SampleClient.as

clean:
	rm -f SampleClient.swf SampleFlashLiteClient.swf
