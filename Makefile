.PHONY: pdf

CFLAGS=-fPIC -Wall -ansi -g -pedantic -O3
SP_LDFLAGS = -lsoundpipe -lsndfile -lm
LDFLAGS=-lsporth $(SP_LDFLAGS) -lpthread -ldl
# for more readable C output:
#CTANGLE=ctanglex +c -l

SPORTH_FILES= sp/test.tex sp/chant.tex sp/unya.tex sp/rant.tex

PLOTS=plots/tract.eps plots/nose.eps \
	  plots/tongueshape1.eps\
	  plots/tongueshape2.eps\
	  plots/tongueshape3.eps\
	  plots/tongueshape4.eps\

WEB=data.w top.w ugen.w glottis.w header.w debug.w tract.w sp.w

CONFIG?=

include $(CONFIG)

default: libvoc.a

pdf: voc.pdf

plugin: voc.so 

library: libvoc.a

version: 
	git rev-parse HEAD > version

voc.tex: voc.w macros.tex $(WEB) $(PLOTS) $(SPORTH_FILES) version
	$(CWEAVE) -x voc.w

voc.dvi: voc.tex 
	tex "\let\pdf+ \input voc"
	bibtex voc

voc.pdf: voc.dvi
	dvipdfm $<

voc.c: voc.w $(WEB) 
	$(CTANGLE) $<

debug.c: voc.c

plot.c: voc.c

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

sp/%.tex: sp/%.sp
	sporth_tex $< > $@ 

voc.so: ugen.c voc.o
	$(CC) $(CFLAGS) -DBUILD_SPORTH_PLUGIN -shared voc.o $< -o $@ $(LDFLAGS)

debug: debug.o voc.c
	$(CC) $(CFLAGS) debug.o voc.c -o $@ $(SP_LDFLAGS)

plot: plot.o voc.c
	$(CC) $(CFLAGS) plot.o voc.c -o $@ $(SP_LDFLAGS)

plots/%.dat: plot
	./plot $@ > $@

plots/%.eps: plots/%.plt  plots/%.dat
	gnuplot $<

libvoc.a: voc.o
	$(AR) rcs $@ voc.o

clean:
	rm -rf voc.tex *.dvi *.idx *.log *.pdf *.sc *.toc *.scn 
	rm -rf *.c
	rm -rf $(SP)
	rm -rf voc.so
	rm -rf *.aux *.bbl *.blg
	rm -rf voc.h
	rm -rf debug
	rm -rf *.o
	rm -rf plot
	rm -rf plots/*.eps
	rm -rf plots/*.dat
	rm -rf version
	rm -rf sp/*.tex
