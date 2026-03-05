set architecture i8086
target remote localhost:1234
symbol-file build/kernel.elf
break _start
