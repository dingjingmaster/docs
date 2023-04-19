curdir = $(shell pwd)

subdirs = docs/gobject


all:
	@for subdir in $(subdirs); \
		do \
		sh -c "pandoc $$subdir/*.md -o aa.pdf "; \
		done

.PHONY: all clean
