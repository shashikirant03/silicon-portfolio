void main() {
    // Stores sequence starting at RAM address 0
    volatile int* ram = (int*) 0x00000000; 

    int a = 0;
    int b = 1;
    int next;

    ram[0] = a;
    ram[1] = b;

    // Calculate the next 5 Fibonacci numbers
    for (int i = 2; i < 7; i++) {
        next = a + b;
        ram[i] = next;
        a = b;
        b = next;
    }

    // Infinite loop to safely halt the CPU
    while(1); 
}