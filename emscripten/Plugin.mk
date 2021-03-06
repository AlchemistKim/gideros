EMCC=$(EMSDK_PREFIX) emcc
BUILD=Build

OPTS=$(POPTS) -O2
ifneq ($(DEBUG),)
OPTS+=-g4 -s ASSERTIONS=1
endif

OBJS=$(addprefix $(BUILD)/,$(addsuffix .em.o,$(SRCS)))
CINCS=$(addprefix -I../,$(INCS))
CFLGS=-DFT2_BUILD_LIBRARY -DDARWIN_NO_CARBON -DHAVE_UNISTD_H \
	-DOPT_GENERIC -DREAL_IS_FLOAT \
	$(OPTS)

all: path $(OBJS)
	@echo "EMLINK" $(TARGET)
	$(EMCC) $(OBJS) -s SIDE_MODULE=1 -s DISABLE_EXCEPTION_CATCHING=0 $(OPTS) -o $(BUILD)/$(TARGET).js
	@if [ "$(BUILD_WASM)" ]; then  @$(EMCC) $(OBJS) -s SIDE_MODULE=1 -s WASM=1 -s DISABLE_EXCEPTION_CATCHING=0 $(OPTS) -o $(BUILD)/$(TARGET).js; fi

path:
	mkdir -p $(sort $(dir $(OBJS)))

clean:
	rm -rf $(BUILD)

$(BUILD)/%.em.o: ../%.cpp
	@echo "EMCC $<"
	@$(EMCC) $(CINCS) $(CFLGS) -std=c++11 -c $< --default-obj-ext .em.o -o $@

$(BUILD)/%.em.o: ../%.c
	@echo "EMCC $<"
	@$(EMCC) $(CINCS) $(CFLGS) -c $< --default-obj-ext .em.o -o $@
