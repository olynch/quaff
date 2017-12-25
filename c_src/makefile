CC=gcc
CFLAGS=-Wall -fpic
# LIBS=-L../external/termbox/build/src
INCLUDE=-I../external/termbox/src -I/nix/store/gq5rav4bjk1521gmm64vwcj5biimh9vl-erlang-19.3.6.4/lib/erlang/erts-8.3.5.3/include
STATIC_LIBS=../external/termbox/build/src/libtermbox.a

libextermbox.so: extermbox.o
	$(CC) $(CFLAGS) -shared -o libextermbox.so extermbox.o $(STATIC_LIBS) -lc

extermbox.o: extermbox.c
	$(CC) $(CFLAGS) $(INCLUDE) -c extermbox.c

clean:
	rm extermbox.o libextermbox.so
