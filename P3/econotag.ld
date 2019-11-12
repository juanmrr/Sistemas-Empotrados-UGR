/*****************************************************************************/
/*                                                                           */
/* Sistemas Empotrados                                                       */
/*                                                                           */
/* Linker script para la Redwire EconoTAG                                    */
/*                                                                           */
/*****************************************************************************/

/*****************************************************************************/
/* Punto de entrada                                                          */
/*****************************************************************************/

ENTRY(_start)

/*
 * Mapa de memoria de la placa
 */
MEMORY
{
        ram0 :  org = 0x00400000,       len = 0x00002000        /* (8 KB) */
	ram1 :  org = 0x00402000,	len = 0x00006000	/* (24KB) */
	ram2 :  org = 0x00408000,	len = 0x00008000	/* (32KB) */
	ram3 :  org = 0x00410000,	len = 0x00008000	/* (32KB) */
	gpio :  org = 0x80000000,	len = 0x00000400	/* (1 KB) */
}

SECTIONS
{
        /* Código del programa */
        .text :
        {
                *(.text);
		. = ALIGN(4);
        } > ram0

	/*.ram1 : ALIGN(4)
        {
                s1 = .;
        } > ram1

	.ram2 : ALIGN(4)
        {
                s2 = .;
        } > ram2

	.ram3 : ALIGN(4)
        {
                s3 = .;
        } > ram3*/

	.data : 
	{
		*(.data);
		. = ALIGN(4);
	} > ram1

	.gpio :
	{
		gpio_pad_dir0 = 	. + 0x00000000;
		gpio_dir_set1 = 	. + 0x0000005c;
		gpio_data0 = 		. + 0x00000008;
		gpio_data_set0 = 	. + 0x00000048;
		gpio_data_set1 = 	. + 0x0000004c;
		gpio_data_reset1 = 	. + 0x00000054;

		. = ALIGN(4);
	} > gpio

}
