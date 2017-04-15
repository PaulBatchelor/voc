OBJ=voc.c
CFLAGS=-fPIC
LDFLAGS=-lsporth -lsoundpipe -lsndfile -lm -lpthread

default: voc.pdf 

SP=sp/test.tex

program: voc.so

voc.tex: voc.w $(SP) macros.tex
	cweave -x voc.w

voc.dvi: voc.tex 
	tex "\let\pdf+ \input voc"

voc.pdf: voc.dvi
	dvipdfm $<

voc.c: voc.w
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
