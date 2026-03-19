static volatile int *uart = (int *)(void *)0x10010000;

#define UART_REG_TXFIFO 0x0

static int putchar(char ch)
{
    while (uart[UART_REG_TXFIFO] < 0);
    return uart[UART_REG_TXFIFO] = ch & 0xFF;
}

struct test {
    int a;
    int b;
    int c;
    int d;
};

static int test_func(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8, int a9, int a10)
{
    return a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10;
}

static int test_func2(struct test B) {
    return B.a;
}

void main(void)
{
    const char *s = "RISCV: Show me the light\n";
    while (*s) putchar(*s++);
    test_func(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    struct test teststruct = {5, 5, 5, 5};
    test_func2(teststruct);
    while (1);
}