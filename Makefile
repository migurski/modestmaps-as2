all: SampleClient.swf SampleFlashLiteClient.swf

SampleClient.swf:
	mtasc -version 8 -header 800:600:31 -main -cp lib -swf SampleClient.swf SampleClient.as

SampleFlashLiteClient.swf:
	mtasc -header 352:408:31 -main -cp lib -swf SampleFlashLiteClient.swf SampleFlashLiteClient.as

clean:
	rm -f SampleClient.swf SampleFlashLiteClient.swf
