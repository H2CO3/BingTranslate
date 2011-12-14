TARGET = BingTranslate

CC = gcc
LD = $(CC)
CFLAGS = -isysroot /User/sysroot \
	 -std=gnu99 \
	 -Wall \
	 -I. \
	 -I.. \
	 -c
LDFLAGS = -isysroot /User/sysroot \
	  -w \
	  -dynamiclib \
	  -install_name /System/Library/Frameworks/$(TARGET).framework/$(TARGET) \
	  -lobjc \
	  -framework Foundation \
	  -framework AVFoundation \
	  -framework CarbonateJSON

OBJECTS = BTClient.o \
	  NSArray+BingTranslate.o \
	  NSDictionary+BingTranslate.o \
	  NSString+BingTranslate.o \
	  NSMutableString+BingTranslate.o \
	  NSURLConnection+BingTranslate.o 

all: $(TARGET)
	sudo cp $(TARGET) /System/Library/Frameworks/$(TARGET).framework/
	sudo cp $(TARGET) /User/sysroot/System/Library/Frameworks/$(TARGET).framework/

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS)

%.o: %.m
	$(CC) $(CFLAGS) -o $@ $^

