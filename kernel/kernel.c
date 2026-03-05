#define TOP_LEFT 201
#define TOP_RIGHT 187
#define BOTTOM_LEFT 200
#define BOTTOM_RIGHT 188
#define HORIZONTAL_PIPE 205
#define VERTICAL_PIPE 186

#define KEY_INT 0x16

typedef struct Point
{
    unsigned short x;
    unsigned short y;
} Point;

typedef struct CommandContext
{
    unsigned char cursor;
    char commandBuffer[128];
    unsigned char offset;
} CommandContext;

typedef struct Environment
{
    Point cursor;
    CommandContext commandContext;
} Environment;

void draw(volatile unsigned short *vga);
void drawc(unsigned short x,
           unsigned short y,
           unsigned char c,
           volatile unsigned short *vga);
void drawxc(unsigned short x,
            unsigned short y,
            unsigned short word,
            volatile unsigned short *vga);

void _start()
{
    unsigned short ax, bx, cx, dx;
    char *command = "Hello, World!";

    // init environment
    Environment env = {
        .cursor = {1, 1},
        .commandContext = {
            .cursor = 0,
            .offset = 0,
            .commandBuffer = {0},
        },
    };

    // set video mode to 80x25 text mode
    ax = 0x0003;
    asm volatile(
        "int 0x10\n\t"
        : "+a"(ax)
        :
        :);

    dx = (env.cursor.y << 8) | env.cursor.x;
    ax = 0x0200;
    asm volatile( // set cursor
        "int 0x10\n\t"
        : "+a"(ax)
        : "d"(dx), "b"(0)
        :);

    // initial draw
    volatile unsigned short *vga = (unsigned short *)0xB8000;

    while (1)
    {
        // unsigned char key;
        // unsigned char scancode;
        // unsigned char no_key;
        // ax = 0x0100;
        // read keyboard status
        // asm volatile(
        //     "int 0x16\n\t"
        //     "setz %0\n\t" // %1 = 1 if no key
        //     : "=q"(no_key)
        //     : "a"(ax)
        //     : "cc");
        // key = ax & 0xFF;
        // scancode = (ax >> 8) & 0xFF;
        draw(vga);
        int cursor = 0;
        while (command[cursor] != '\0')
        {
            vga[1 * 80 + cursor + 1] = (0x1E << 8) | command[cursor];
            cursor++;
        }

        // wait
        unsigned char success;
        ax = 0x8600;
        cx = 0;
        dx = 33333;
        asm volatile(
            "int 0x15\n\t"
            "setc al\n\t"
            "mov %0, al\n\t"
            : "=q"(success)
            : "a"(0x8600), "c"(0), "d"(33333)
            : "cc");
        bx = 0x0000;
    }
}

void drawxc(unsigned short x,
            unsigned short y,
            unsigned short word,
            volatile unsigned short *vga)
{
    char toChar[5];
    toChar[4] = '\0';
    for (int i = 0; i < 4; i++)
    {
        unsigned char nibble = (word & 0x0F << (i * 4)) >> (i * 4) & 0x0F;
        unsigned char character;
        if (nibble < 10) {
            character = '0' + nibble;
        } else {
            character = 'A' + (nibble - 10);
        }
        toChar[i] = character;
        drawc(x + i, y, character, vga);
    }
}

void drawc(unsigned short x,
           unsigned short y,
           unsigned char c,
           volatile unsigned short *vga)
{
    vga[y * 80 + x] = (0x1E << 8) | c;
}

void draw(volatile unsigned short *vga)
{
    for (unsigned short x = 0; x < 80; x++)
    {
        for (unsigned short y = 0; y < 25; y++)
        {
            unsigned char character;
            if (x == 0 && y == 0)
            {
                character = TOP_LEFT;
            }
            else if (x == 0 && y == 24)
            {
                character = BOTTOM_LEFT;
            }
            else if (x == 79 && y == 0)
            {
                character = TOP_RIGHT;
            }
            else if (x == 79 && y == 24)
            {
                character = BOTTOM_RIGHT;
            }
            else if (x == 0 || x == 79)
            {
                character = VERTICAL_PIPE;
            }
            else if (y == 0 || y == 24)
            {
                character = HORIZONTAL_PIPE;
            }
            else
            {
                character = 0;
            }
            drawc(x, y, character, vga);
        }
    }
}

