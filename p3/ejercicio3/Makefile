LIBS =
LIB_DIR =
FLAGS = -g -Wall -D_GNU_SOURCE

all: multNormal multTraspuesta

multNormal: multNormal.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multTraspuesta: multTraspuesta.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *~ fast slow multNormal multTraspuesta *.o
