CC=gcc


TARGET=tiny_ml
OBJDIR=./obj/
SRC=./src/

CLFAGS=-w -lm -lpthread

LAYER_OBJ=activation_layer.o convolution_layer.o maxpool_layer.o fc_layer.o
LAYER_OBJS = $(addprefix $(OBJDIR), $(LAYER_OBJ))

TAR_OBJ=inference_model.o 
TAR_OBJS = $(addprefix $(OBJDIR), $(TAR_OBJ))

$(OBJDIR):
	mkdir -p $(OBJDIR) 

$(TARGET): $(TAR_OBJS) $(LAYER_OBJS) 
	$(CC) -o $(OBJDIR)matrix.o -c $(SRC)matrix.c $(CLFAGS)
	$(CC) -o $@	$(SRC)tiny_ml.c $(TAR_OBJS) $(LAYER_OBJS) $(OBJDIR)matrix.o $(CLFAGS)

$(TAR_OBJS):
	$(CC) -o $(OBJDIR)inference_model.o -c $(SRC)inference_model.c $(CLFAGS)

$(LAYER_OBJS):
	$(CC) -o $(OBJDIR)activation_layer.o -c $(SRC)activation_layer.c $(CLFAGS)
	$(CC) -o $(OBJDIR)convolution_layer.o -c $(SRC)convolution_layer.c $(CLFAGS)
	$(CC) -o $(OBJDIR)maxpool_layer.o -c $(SRC)maxpool_layer.c $(CLFAGS)
	$(CC) -o $(OBJDIR)fc_layer.o -c $(SRC)fc_layer.c $(CLFAGS)


all: $(OBJDIR) $(TARGET)


clean: 
	rm -rf $(OBJDIR) $(TARGET)