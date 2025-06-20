# Nome do executável
TARGET=montador

# Fontes
SRCS=montador.c

# Compilador
CC=gcc

# Flags de compilação
CFLAGS=-Wall -O2

# Regra padrão
all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET)