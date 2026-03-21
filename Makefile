PLENARY := .deps/plenary.nvim

test: $(PLENARY)
	nvim --headless -u tests/minimal_init.lua \
	  -c "PlenaryBustedDirectory tests/disunion/ {minimal_init='tests/minimal_init.lua'}"

$(PLENARY):
	mkdir -p .deps
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $@

.PHONY: test
