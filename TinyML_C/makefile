CC=gcc


TARGET=alexnet
OBJDIR=./obj/
SRC=./src/

CLFAGS=-w -lm -lpthread

LAYER_OBJ=activation_layer.o convolution_layer.o maxpooling_layer.o fc_layer.o
LAYER_OBJS = $(addprefix $(OBJDIR), $(LAYER_OBJ))

TAR_OBJ=train.o inference.o data.o
TAR_OBJS = $(addprefix $(OBJDIR), $(TAR_OBJ))

