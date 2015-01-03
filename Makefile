
all: test


test:
	xcodebuild -scheme StringFormat test

.PHONY: all test
