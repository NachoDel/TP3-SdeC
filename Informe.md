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











