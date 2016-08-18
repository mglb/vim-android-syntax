PLUGIN_NAME := android_syntax

VIMRC := $(PLUGIN_NAME).vimrc

define VIMRC_CONTENT
if filereadable("/etc/vim/vimrc")
	so /etc/vim/vimrc
endif
if filereadable("$$HOME/.vimrc")
	so $$HOME/.vimrc
endif
filetype off
set runtimepath^=$(CURDIR)
filetype on
endef
export VIMRC_CONTENT


all: test_vim

$(VIMRC): Makefile
	echo "$$VIMRC_CONTENT" > $@

test_vim: $(VIMRC)
	vim --not-a-term -u $(VIMRC)


clean:
	rm -f $(VIMRC)

.PHONY: test_vim clean

