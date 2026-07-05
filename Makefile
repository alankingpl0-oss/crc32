# Flagi kompilacji i linkowania
ASM = nasm
ASM_FLAGS = -f elf64
LD = ld

# Nazwa pliku wynikowego
TARGET = crc

all: $(TARGET)

$(TARGET): szyfrator.o
	$(LD) -o $(TARGET) szyfrator.o

szyfrator.o: main.asm
	$(ASM) $(ASM_FLAGS) main.asm -o szyfrator.o

clean:
	rm -f *.o $(TARGET)

