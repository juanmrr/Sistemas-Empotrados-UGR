/*****************************************************************************/
/*                                                                           */
/* Sistemas Empotrados                                                       */
/* Comprobación de la gestión de excepciones                                 */
/*                                                                           */
/*****************************************************************************/

#include <stdint.h>
#include "system.h"

/*
 * Constantes relativas a la plataforma
 */

/* Dirección del registro de control de dirección del GPIO32-GPIO63 */
volatile uint32_t * const reg_gpio_pad_dir1    = (uint32_t *) 0x80000004;

/* Dirección del registro de activación de bits del GPIO32-GPIO63 */
volatile uint32_t * const reg_gpio_data_set1   = (uint32_t *) 0x8000004c;

/* Dirección del registro de limpieza de bits del GPIO32-GPIO63 */
volatile uint32_t * const reg_gpio_data_reset1 = (uint32_t *) 0x80000054;

/* El led rojo está en el GPIO 44 (el bit 12 de los registros GPIO_X_1) */
uint32_t const led_red_mask = (1 << (44-32));

/* El led verde está en el GPIO 45 (el bit 13 de los registros GPIO_X_1) */
uint32_t const led_green_mask = (1 << (45-32));

/*
 * Constantes relativas a la aplicacion
 */
uint32_t const delay = 0x10000;

/*****************************************************************************/

/*
 * Inicialización de los pines de E/S
 */
void gpio_init(void)
{
	/* Configuramos los GPIO44 y GPIO45 para que sean de salida */
	*reg_gpio_pad_dir1 = led_red_mask | led_green_mask;
}

/*****************************************************************************/

/*
 * Enciende los leds indicados en la máscara
 * @param mask Máscara para seleccionar leds
 */
void leds_on (uint32_t mask)
{
	/* Encendemos los leds indicados en la máscara */
	*reg_gpio_data_set1 = mask;
}

/*****************************************************************************/

/*
 * Apaga los leds indicados en la máscara
 * @param mask Máscara para seleccionar leds
 */
void leds_off (uint32_t mask)
{
	/* Apagamos los leds indicados en la máscara */
	*reg_gpio_data_reset1 = mask;
}

/*****************************************************************************/

/*
 * Retardo para el parpedeo
 */
void pause(void)
{
        uint32_t i;
	for (i=0 ; i<delay ; i++);
}

/*****************************************************************************/

/*
 * Gestiona las instrucciones no definidas
 */
__attribute__ ((interrupt ("UNDEF")))
void my_undef_handler (void)
{
        /*
         * De momento sólo encendemos el led verde para informar de que se ha
         * captado una instrucción no válida, la ignoramos, y seguimos con la
         * ejecución del programa
         */
        leds_on (led_green_mask);
}

/*****************************************************************************/

/*
 * Máscara del led que se hará parpadear
 */
uint32_t the_led;

/*
 * Programa principal
 */
int main ()
{
	gpio_init();

        /* Instalamos el manejador para las instrucciones no válidas */
        excep_set_handler (excep_undef, my_undef_handler);

        the_led = led_red_mask;

        /*
         * Forzamos uns instrucción no válida:
         * Si el manejador se ha instalado correctamente, se debería encender
         * el led verde y retornar para seguir con la ejecución del programa
         */
        asm(".word 0x26889912\n");

	while (1)
	{
		leds_on(the_led);
                pause();

		leds_off(the_led);
                pause();
	}

        return 0;
}

/*****************************************************************************/

