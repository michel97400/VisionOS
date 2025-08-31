#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <stdint.h>

void keyboard_init();
char keyboard_get_char();   // Retourne le prochain caractère ASCII ou 0 si rien
void keyboard_update();     // Lit le port et met à jour l’état du clavier

#endif
