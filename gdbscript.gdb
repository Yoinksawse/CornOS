add-symbol-file ./bin/completeKernel.o 0x100000
break kmain
target remote localhost:1234
continue