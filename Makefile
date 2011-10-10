flash:
	cd lib && mxmlc -static-link-runtime-shared-libraries -output=../MediaCapture.swf MediaCapture.as

test:
	@echo "populate me"

.PHONY: flash test