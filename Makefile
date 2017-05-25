CFLAGS=-fPIC -Wall -ansi -g -pedantic -O3
SP_LDFLAGS = -lsoundpipe -lsndfile -lm
LDFLAGS=-lsporth $(SP_LDFLAGS) -lpthread -ldl

SPORTH_FILES= sp/test.tex

PLOTS=plots/tract.eps plots/nose.eps \
	  plots/tongueshape1.eps\
	  plots/tongueshape2.eps\
	  plots/tongueshape3.eps\

WEB=data.w top.w ugen.w glottis.w header.w debug.w tract.w

CONFIG?=

include $(CONFIG)

default: voc.pdf 

program: voc.so

version: 
	git rev-parse HEAD > version

voc.tex: voc.w macros.tex $(WEB) $(PLOTS) $(SPORTH_FILES) version
	cweave -x voc.w

voc.dvi: voc.tex 
	tex "\let\pdf+ \input voc"
	bibtex voc

voc.pdf: voc.dvi
	dvipdfm $<

voc.c: voc.w $(WEB) 
	ctangle $<

debug.c: voc.c

plot.c: voc.c

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

sp/%.tex:sp/%.sp
	cat $< | sed "s/_/\\\\_/g" | sed "s/#/\\\\#/" | sed "s/$$/\\n/"> $@ 

voc.so: ugen.c voc.c
	$(CC) $(CFLAGS) -DBUILD_SPORTH_UGEN -shared voc.o $< -o $@ $(LDFLAGS)

debug: debug.o voc.c
	$(CC) $(CFLAGS) debug.o voc.c -o $@ $(SP_LDFLAGS)

plot: plot.o voc.c
	$(CC) $(CFLAGS) plot.o voc.c -o $@ $(SP_LDFLAGS)

plots/%.dat: plot
	./plot $@ > $@

plots/%.eps: plots/%.plt  plots/%.dat
	gnuplot $<

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
