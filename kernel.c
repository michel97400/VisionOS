// Indique au linker que kmain est global
void kmain(void) __attribute__((noreturn)); // optionnel mais conseillé
void kmain(void)
{
    char* video_memory = (char*)0xB8000;
    for(int i=0;i<80*25*2;i+=2){video_memory[i]=' '; video_memory[i+1]=0x07;}
    const char* msg="Bonjour, OS !";
    int i=0;
    while(msg[i]){video_memory[i*2]=msg[i]; video_memory[i*2+1]=0x07;i++;}
    while(1){__asm__ volatile("hlt");}
}
