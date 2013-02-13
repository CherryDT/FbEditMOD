BUILDDIR = bin
CFLAGS  = -Wall -DHAVE_CONFIG_H -I.
LDFLAGS = -lintl -liconv
OBJ = $(addprefix $(BUILDDIR)/, \
	regerror.o regexec.o regcomp.o tre-ast.o tre-compile.o \
	tre-match-approx.o tre-match-backtrack.o tre-match-parallel.o \
	tre-parse.o tre-mem.o tre-stack.o)

all: tre

clean:
	rm -rf bin

tre: $(OBJ)
	$(CC) -shared -o $(BUILDDIR)/tre.dll -Wl,--out-implib,$(BUILDDIR)/libtre.dll.a $(OBJ) $(LDFLAGS)
	ar rcs $(BUILDDIR)/libtre.a $(OBJ)

$(BUILDDIR)/%.o: %.c | $(BUILDDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)
	