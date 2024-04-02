export BUILD_PATH ?= /app/build
RM                  = rm -rf
BIN_PATH            = $(BUILD_PATH)/bin
PATHS 	            = $(BIN_PATH)

$(BIN_PATH)/helloworld: | $(PATHS)
	$(CC) $(CFLAGS) -o $@ helloworld.c

$(PATHS):
	mkdir -p $@

clean:
	$(RM) $(BIN_PATH)

.PHONY: clean
