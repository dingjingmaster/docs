curdir = $(shell pwd)

subdirs = gobject


all:
	@for subdir in $(subdirs); \
		do \
		sh -c "${curdir}/bin/transform-md-to-tex.sh $$subdir"; \
		done
	@sh -c "${curdir}/bin/pandoc-warp.sh ${curdir}/docs/index.md ${curdir}/latex/index.tex"
	@cd latex; lualatex index.tex
	@cd $(curdir); mv "$(curdir)/latex/index.pdf" "$(curdir)/Linux C&C++ 开发文档.pdf"

.PHONY: all clean

clean:
	@rm -rf "$(curdir)/latex"
	@rm -f *.pdf
