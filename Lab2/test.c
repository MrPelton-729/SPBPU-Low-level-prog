#include <stdint.h>

#define UART_REG_TXFIFO 0x0

#define UART_BASE_ADDR 0x10010000
#define CLINT_BASE_ADDR 0x2000000
#define CLINT_MTIME_OFFSET 0xBFF8
#define CLINT_MTIMECMP_OFFSET 0x4000 // offset for hart #0
#define MTIME_MAX 0xFFFFFFFFFFFFFFFF

void end(void) asm("end");
void timer_setup(int enable) asm("timer_setup");

static volatile int *mtime_addr = (uint64_t*)(CLINT_BASE_ADDR + CLINT_MTIME_OFFSET);
static volatile int *mtimecmp_addr = (uint64_t*)(CLINT_BASE_ADDR + CLINT_MTIMECMP_OFFSET);

static volatile int *uart = (int *)(void *)UART_BASE_ADDR;

static void sys_putchar(char ch) {
    register unsigned long a7 asm("a7") = 1;
    register unsigned long a0 asm("a0") = ch;
    asm volatile("ecall" : : "r"(a7), "r"(a0) : "memory");
}

static void sys_enable_timer(void) {
    register unsigned long a7 asm("a7") = 2;
    asm volatile("ecall" : : "r"(a7) : "memory");
}

static void sys_set_timer_cmp(uint64_t value) {
    register unsigned long a7 asm("a7") = 3;
    register unsigned long a0 asm("a0") = value;
    asm volatile("ecall" : : "r"(a7), "r"(a0) : "memory");
}

static void print_string(const char *s) {
    while (*s) sys_putchar(*s++);
}

// ----- Прямой вывод в UART (только для M-режима) -----
static void putchar_m(char ch) {
    while (uart[UART_REG_TXFIFO] < 0);
    uart[UART_REG_TXFIFO] = ch & 0xFF;
}

static void print_string_m(const char *s) {
    while (*s) putchar_m(*s++);
}

// ----- Основная программа (U-режим) -----
void main(void) {
    print_string("Student: Platon Saveliev\n");

    sys_enable_timer();                       

    uint64_t now = *mtime_addr;
    sys_set_timer_cmp(now + 1000000);         

    asm volatile("wfi");                      

    print_string("Program finished\n");
    end();
}

long handle_trap(long cause, long epc, long regs[32]) {
    if (cause & (1L << 63)) {                
        long code = cause & ((1L<<63)-1);
        if (code == 7) {                     
            timer_setup(0);                  
            return epc;                      
        } else {
            print_string_m("Unknown interrupt\n");
            end();
            return epc;
        }
    } else {                                 
        if (cause == 8) {                    
            long syscall_num = regs[17];     
            if (syscall_num == 1) {
                putchar_m((char)regs[10]);   
                return epc + 4;              
            } else if (syscall_num == 2) {
                timer_setup(1);              
                *mtimecmp_addr = MTIME_MAX;  
                return epc + 4;
            } else if (syscall_num == 3) {
                *mtimecmp_addr = (uint64_t)regs[10]; 
                return epc + 4;
            } else {
                print_string_m("Unknown syscall\n");
                end();
                return epc;
            }
        } else {
            print_string_m("Unknown exception\n");
            end();
            return epc;
        }
    }
}