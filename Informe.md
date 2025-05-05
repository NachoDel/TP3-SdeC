# Universidad Nacional de Córdoba

![][image1]

### *Facultad de ciencias exactas, físicas y naturales*

##### Sistemas de Computación – Practico \#3 Modo Protegido

##### Alumnos: 
- Delamer, Ignacio
- Rivarola, Ignacio Agustin
- Verstraete, Enzo Gabriel

## **Objetivo General**
Se platearon 3 desafios teoricos y  practicos a resolver, cada uno trata un tema en particular:
* **Desafío: UEFI y coreboot**
* **Desafío: Linker**
* **Desafío final: Modo protegido**

## **Dearrollo**
### **Desafio: UEFI y Coreboot**
A. ¿Qué es UEFI? ¿comó puedo usarlo? Mencionar además una función a la que podría llamar usando esa dinámica.  
  
UEFI (Unified Extensible Firmware Interface) es una interfaz moderna que reemplaza al antiguo BIOS en las computadoras. Se encarga de iniciar el hardware y preparar el entorno para que el sistema operativo pueda cargarse. Se puede interactuar con UEFI al encender la computadora y acceder a la configuración del firmware (normalmente presionando teclas como F2, Esc o Supr durante el arranque).
Una función interesante dentro de UEFI es el Secure Boot. Esta característica verifica la firma de los sistemas operativos antes de permitir su carga, lo que ayuda a prevenir la ejecución de software malicioso al inicio. Puedes habilitar o deshabilitar esta opción en la configuración de UEFI, dependiendo de tus necesidades.  
  
B. Menciona casos de bugs de UEFI que puedan ser explotados.  
  
BlackLotus Bootkit: Este es un malware avanzado que puede evadir el Secure Boot, una característica diseñada para proteger el proceso de arranque. BlackLotus aprovecha vulnerabilidades en el firmware UEFI para instalarse y persistir incluso después de reinstalar el sistema operativo.  
El BlackLotus Bootkit explota principalmente la vulnerabilidad conocida como CVE-2022-21894, también llamada Baton Drop. Esta vulnerabilidad permite realizar un rollback de los gestores de arranque de Windows a versiones anteriores que no están protegidas en la base de datos de firmas prohibidas de Secure Boot (DBX).  
Esto le permite al malware:  
* Bypassear el Secure Boot, una medida clave de seguridad.  
* Instalar archivos maliciosos en la partición del sistema EFI (ESP), que son ejecutados por el firmware UEFI.  
* Desactivar características de seguridad como BitLocker, Microsoft Defender Antivirus y la integridad del código protegido por hipervisor (HVCI).  

Estas acciones aseguran que el malware pueda persistir y operar con privilegios elevados desde el arranque del sistema, para más información se pone el link del articulo que lo describe: https://arstechnica.com/information-technology/2023/03/unkillable-uefi-malware-bypassing-secure-boot-enabled-by-unpatchable-windows-flaw/
  
C. ¿Qué es Converged Security and Management Engine (CSME), the Intel Management Engine BIOS Extension (Intel MEBx)?  

El Converged Security and Management Engine (CSME) y el Intel Management Engine BIOS Extension (Intel MEBx) son tecnologías desarrolladas por Intel para mejorar la seguridad y la gestión de sistemas informáticos.  
El CSME es una plataforma integrada en los procesadores Intel que proporciona funciones de seguridad y gestión. Sus principales características incluyen:  
* Inicialización del hardware: Garantiza que el sistema se configure correctamente desde el inicio.
* Gestión remota: Permite a los administradores controlar dispositivos de forma remota, incluso cuando están apagados.
* Seguridad avanzada: Implementa medidas como cifrado y autenticación para proteger datos y prevenir accesos no autorizados.

El Intel MEBx es una interfaz que permite configurar las funciones de gestión remota proporcionadas por Intel Management Engine (ME). Algunas de sus capacidades incluyen:  
* Configuración de Intel Active Management Technology (AMT), que facilita la administración remota de dispositivos.
* Ajustes de seguridad, como contraseñas y opciones de red.

D. ¿Qué es coreboot ? ¿Qué productos lo incorporan ?¿Cuales son las ventajas de su utilización?  

Coreboot es un firmware de código abierto diseñado para reemplazar el BIOS o UEFI en sistemas informáticos. Su objetivo principal es inicializar el hardware y cargar un sistema operativo de manera rápida y eficiente, eliminando características innecesarias y mejorando la seguridad.  
Coreboot es utilizado en dispositivos como:  
* Chromebooks: La mayoría de los Chromebooks vienen con Coreboot preinstalado.
* Laptops de fabricantes como System76 y Purism: Estas marcas ofrecen dispositivos con Coreboot para garantizar mayor control y transparencia.
* Servidores y sistemas embebidos: Coreboot es popular en entornos donde la velocidad y la personalización son esenciales.

Ventajas de Coreboot:
* Código abierto: Ofrece transparencia y la posibilidad de personalizar el firmware según las necesidades del usuario.
* Arranque rápido: Coreboot está diseñado para minimizar el tiempo de inicio del sistema.
* Seguridad mejorada: Reduce la superficie de ataque al eliminar componentes innecesarios y soporta procesos de arranque seguro como VBOOT2.
* Flexibilidad: Permite usar diferentes payloads para adaptarse a diversas necesidades, como SeaBIOS para sistemas más antiguos o Tianocore para compatibilidad con UEFI.
* Compatibilidad con hardware variado: Funciona en una amplia gama de plataformas, desde laptops hasta servidores.


### **Desafio: Linker**  
A. ¿Qué es un linker?¿qué hace?  

El Linker es una herramienta, la cual toma uno o varios ficheros objeto generados por el ensamblador/compilador y los combina para producir un ejecutable (como una imagen binaria).  
A continuación enumeramos las funciones principales:  
* Resolución de símbolos: Une llamadas a funciones y referencias a variables con sus definiciones reales, resolviendo referencias externas entre objeto.
* Reubicación (relocation): justa direcciones de código y datos según la posición en memoria donde se vaya a cargar la imagen final. Para ello usa la tabla de relocaciones que generan compilador/ensamblador.
* Agrupación de secciones: Según un script de linker, toma las secciones (.text, .data, .bss, etc.) y las ubica en rangos de direcciones concretas para generar la estructura final del archivo.
* Generación de la salida: Produce el ejecutable en formato ELF, PE, Mach-O, o —en nuestro caso de bootloader— raw binary (sin cabeceras), que luego podrá copiarse al sector de arranque.

B. ¿Cuál es la dirección que aparece en el script del linker?¿Porqué es necesaria?  

La dirección que aparece en el script del linker (. = 0x7c00;), establece el contador de ubicación (.) al valor físico 0x7C00, que es donde la BIOS carga el sector 0 del disco en modo real. Esa dirección VMA (virtual memory address) se usa para calcular los desplazamientos de todas las instrucciones y referencias a datos. Si el linker no sabe en qué dirección va a quedar el código, no puede parchear correctamente las referencias.  

C. Compare la salida de objdump con hd, verifique donde fue colocado el programa dentro de la imagen.  

A la hora de ver el resultado de objdump obtenemos lo siguiente:  
IMAGEN_OBJDUMP  
Aqui observamos la direccion virtual donde vive cada instruccion.  
* La primera instrucción en 0x7C00 es mov $0x7c10, %si (bytes be 10 7c).  
* Luego, el bucle de impresión utiliza lods e int 0x10 para mostrar caracteres.
* Los jmp y nop (dec %ax, outs, insb, etc.) corresponden a relleno o instrucciones del mensaje.
  
Y ahora si vemos el resultado de hd:
IMAGEN_HD  
* Offset 0x00 en el archivo contiene be 10 7c, que corresponde al mov $0x7c10, %si mostrado en objdump a 0x7C00.
* Offset 0x0F (90 o instrucción de relleno) y 0x10 (48, primer byte de "H") coinciden con las direcciones 0x7C0F y 0x7C10 en la vista de objdump.
* Los bytes ASCII de "Hola Mundo" (48 6f 6c 61 20 4d 75 6e 64 6f) aparecen en offset 0x10 del archivo, y en memoria a 0x7C10.
  
Mapeo de offset a direccion virtual:
* Cualquier byte en el archivo en offset n se mapea a la dirección 0x7C00 + n en memoria.
* Ejemplo: el byte 0x48 ('H') en offset 0x10 aparece a 0x7C10 → mov $0x7c10, %si carga ese puntero.
Con este análisis, podemos observar cómo la salida de objdump y hd coinciden y asi confirmar la ubicación exacta del código y los datos dentro de la imagen del bootloader.

D. Grabar la imagen en un pendrive y probarla en una pc y subir una foto.  

Para realizar esta actividad, escribimos un codigo el cual debe mostrar “Hola mundo” acompañado del nombre del grupo en la pantalla. Debido a que tuvimos problemas para ejecutarlo desde el pendrive (la bios nos salteaba el boot desde el pendrive y ejecutaba directamente el SO), decidimos optar por la ejecución en una maquina virtual (QEMU) y obtuvimos lo siguiente:  
IMAGEN_HOLAMUNDO

E. ¿Para que se utiliza la opción --oformat binary en el linker?  

La opción --oformat binary en el linker, se utiliza para indicar al linker que no genere un ejecutable en formato ELF (con cabeceras, secciones, tablas, etc.), sino que saque directamente los bytes de las secciones .text/.data/.bss agrupadas según el script. El resultado es un raw image listo para copiar en un sector de arranque o volcar con dd a una partición sin más envoltorio.  

### **Desafio final: Modo Protegido**  
A. Crear un código assembler que pueda pasar a modo protegido (sin macros).

El codigo se encuentra en el archivo Modo_protegido.asm dentro de la carpeta vscode.  
Básicamente en este codigo observamos que se crea una GDT con descriptor nulo, uno de código (base=0, 4GiB, exec+read) y uno de datos (base=0x00200000, R/W) separados. Tambien se ajustan los bits de acceso para diferenciarlos. Y por ultimo, tras cargar la GDT, se activa PE y se salta a código 32-bit.  

B. ¿Cómo sería un programa que tenga dos descriptores de memoria diferentes, uno para cada segmento (código y datos) en espacios de memoria diferenciados?  

Un programa que tenga dos descriptores de memoria diferentes, deberia tener la siguiente pinta:  
Código: Selector 0x08, apunta al segundo descriptor en GDT.  
Datos: Selector 0x10, apunta al tercer descriptor en GDT.  
Elegimos la base de datos en 0x00200000 para diferenciar espacios.  

C. Cambiar los bits de acceso del segmento de datos para que sea de solo lectura,  intentar escribir, ¿Que sucede? ¿Que debería suceder a continuación? (revisar el teórico) Verificarlo con gdb.  

Modificamos el archivo Modo_protegido.asm, especificamente la linea 46 pasamos de db 10010010b a db10010000b y en pm_entry luego de cargar todos los registros de segmento con el selector de datos vamos a agregar mov dword [0x00200000], 0xDEADBEEF que intentara escribir el segmento de datos.  
Lo que sucede es que al intertar escribir el segmento que esta en modo solo lectura esto causa excepcion correspondiente a una General Protection Fault (GPF). A continuacion, si tenés configurado un manejador para la interrupción 0x0D, el sistema operativo (o tu código si estás en bare-metal) maneja la excepción (por ejemplo, mostrando un error, matando el proceso, etc.), si no hay un manejador válido, el sistema puede detenerse o reiniciarse (dependiendo del entorno).  
  
En nuestro caso especifico, la ejectucion se corta y se cierra abruptamente la maquina virtual QEMU esto se debe a que salto la General Protection Fault (GPF) y como no tenemos un manejador de de excepciones para capturar la GPF y manejarla adecuadamente la maquina virtual lo interpreta como una falla y cierra la ejecucion.  
Para verificarlo vamos a configurar para que QEMU trate la excepcion y ver los registros en ese momento, esta informacion de salida se guardara en el archivo Salida_QEMU.txt que esta dentro de la carpeta vscode. Analisis:  
1- Excepcion detectada "check_exception old: 0x8 new 0xd" Esto indica que ocurrió una excepción 0x0D, que corresponde a una General Protection Fault (GPF).  
  
2- Estado de los registros en el momento de la excepción:  
   EAX=00000010 EBX=00000000 ECX=00000000 EDX=00000080  
   ESI=00000000 EDI=00000000 EBP=00000000 ESP=00007c00  
   EIP=00007c48 EFL=00000006 [-----P-] CPL=0 II=0 A20=1 SMM=0 HLT=0  
     
   * EIP=00007c48: La instrucción que causó la excepción está en la dirección 0x7C48. Esto corresponde a la línea de código donde se intenta escribir en el segmento de datos.  
   * FL=00000006: Los flags indican que no hay interrupciones habilitadas (IF=0), lo cual es correcto para evitar interferencias.
  
3- Segmentos de la GDT:  
   ES =0010 00200000 ffffffff 00cf9100 DPL=0 DS   [--A]  
   CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]  
   SS =0000 00000000 0000ffff 00009300 DPL=0 DS16 [-WA]  
   DS =0010 00200000 ffffffff 00cf9100 DPL=0 DS   [--A]  
   * DS=0010: El segmento de datos está configurado correctamente con el selector 0x10 (índice 2 en la GDT).  
   * DPL=0: El nivel de privilegio del segmento es 0 (Ring 0).  
   * [--A]: El segmento está configurado como solo lectura (Access Byte = 10010000b), lo que confirma que la configuración de la GDT es correcta.  
  
4- Registro de control CR0: CR0=00000011, El bit PE (Protection Enable) está activado (CR0[0]=1), lo que confirma que estás en modo protegido.  
5- Dirección de la GDT: GDT=00007c1e 00000017, La GDT está ubicada en la dirección 0x7C1E con un tamaño de 0x17 bytes, lo cual coincide con nuestra configuración.  

Con esto podemos afirmar que la excepción General Protection Fault (GPF) ocurrió porque intentamos escribir en un segmento configurado como solo lectura y esto confirma que el descriptor de datos en la GDT está funcionando correctamente.  

D. En modo protegido, ¿Con qué valor se cargan los registros de segmento ? ¿Porque?  

Los registros de segmento, en modo protegido se cargan de la siguiente manera:  
* Al entrar a modo protegido, CS = CODE_SEL (0x08).
* Los registros de datos DS, ES, FS, GS, SS = DATA_SEL (0x10).
Esto se debe a que el far jump inicial (jmp CODE_SEL:pm_entry) recarga CS con el selector de código correcto, y luego cargamos manualmente DS...SS con el selector de datos.






   











