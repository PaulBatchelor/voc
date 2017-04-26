OBJ=voc.c
CFLAGS=-fPIC -Wall -ansi
LDFLAGS=-lsporth -lsoundpipe -lsndfile -lm -lpthread

WEB=data.w top.w ugen.w glottis.w header.w

default: voc.pdf 

SP=sp/test.tex

program: voc.so

voc.tex: voc.w $(SP) macros.tex $(WEB)
	cweave -x voc.w

voc.dvi: voc.tex 
	tex "\let\pdf+ \input voc"
	bibtex voc

voc.pdf: voc.dvi
	dvipdfm $<

voc.c: voc.w $(WEB) 
	ctangle $<

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

sp/%.tex:sp/%.sp
	cat $< | sed "s/_/\\\\_/g" | sed "s/#/\\\\#/" | sed "s/$$/\\n/"> $@ 

voc.so: $(OBJ)
	$(CC) $(CFLAGS) -shared $(OBJ) -o $@ $(LDFLAGS)

clean:
	rm -rf voc.tex *.dvi *.idx *.log *.pdf *.sc *.toc *.scn 
	rm -rf *.c
	rm -rf $(SP)
	rm -rf voc.so
	rm -rf *.aux *.bbl *.blg
	rm -rf voc.h
