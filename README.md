# OpenMpi-Singularity-OpenFoam

El objetivo de de este repositorio es ofrecer una implementación para ejecutar proyectos OpenFOAM en un ambiente distribuído, utilizando Singularity y Open Mpi.

## Herramientas utilizadas

Con la finalidad de llevar a cabo el objetivo principal del proyecto, se utilizó una herramienta desarrollada por el usuario Fatih Ertinaz de github, en el repositorio [fertinaz/Singularity-Openfoam](https://github.com/fertinaz/Singularity-Openfoam), la cual implementa una imagen de Singularity que contiene openFOAM, y permite la ejecución de proyectos por medio de un contenedor.

Para lograr un correcto acoplamiento de la herramienta, se fabricaron algunos scripts incluídos en este repositorio, los cuales se encargan del aprovisionamiento de la misma y sus dependencias, dentro del entorno donde se ejecuta el contenedor, que en este caso, serán dos máquinas virtuales con el sistema operativo linux, en su distribución Centos 8, contruídas con `VirtualBox` y provisionadas por medio de `Vagrant`.

## Puesta en marcha

Se recomienda para la reproducción de la solución implementada, contar con una distribución de linux que soporte las librerías `nfs-common` y `nfs-kernel-server`, que serán necesarias para el montaje del sistema de archivos compartidos. También es necesario contar con la instalación de `VirtualBox` y `Vagrant` en la máquina.

Una vez contamos con esto, podemos descargar los archivos del repositorio.

```bash
$ git clone https://github.com/jaoa12or/OpenMpi-Singularity-OpenFoam.git
```
Cuya estructura es la siguiente:
```
OpenMpi-Singularity-OpenFoam
├─ .gitignore
├─ README.md
├─ Vagrantfile
├─ client.sh
├─ script.sh
└─ shares
   ├─smallPoolFire3D
   └─ nodes

```
Una vez descargada la carpeta, se debe ingresar a ella y correr el comando vagrant up, el cual inicia el despliegue y aprovisionamiento de las máquinas virtuales de `VirtualBox` que utilizaremos. El proceso tarda alrededor de 15 minutos. Durante el proceso de despliegue, es posible que se requiera el ingreso de las credenciales de la máquina, para realizar acondicionamientos adicionales.

Luego de desplegadas las máquinas, debemos ingresar por medio de ssh para realizar una configuración adicional, la cual nos permitirá el paso de mensajes por medio de ssh sin necesidad de una contraseña entre las máquinas, condición necesaria para el correcto funcionamiento de Open Mpi.

Una vez adentro, utilizamos el comando vi para editar un archivo de configuración de ssh: `vi /etc/ssh/ssh_config`, una vez dentro del archivo, se debe descomentar la línea “PasswordAuthentication yes”, luego se deben guardar los cambios y posteriormente salir del editor. Este procedimiento se debe realizar en las dos máquinas virtuales. una vez modificado el archivo, se procede a reiniciar el servicio sshd, para acoger los nuevos cambios, con el comando `sudo service sshd restart`.

Luego de configurar el archivo, se deben generar ssh keys para cada máquina y se deben incluir estas claves en el archivo `authorized_keys` en cada máquina. Si se tienen dudas en este proceso, se puede consultar este [enlace](https://www.itzgeek.com/how-tos/linux/centos-how-tos/how-to-setup-ssh-passwordless-login-on-centos-8-rhel-8.html#manual), que ofrece una guía para este proceso.

Una vez configurado el acceso por ssh en cada máquina, estará dispuesto todo lo necesario para la ejecución del proyecto de OpenFOAM.

Con el fin de probar el correcto funcionamiento de la solución implementada, se utilizó uno de los proyectos demo que incluye la instalación de OpenFOAM. Para tener acceso al proyecto demo que se utilizará para el proceso de prueba y puesta en marcha, debemos remitirnos a la carpeta shares, que se encuentra entre los archivos descargados del repositorio y es la carpeta sincronizada por [NFS](https://es.wikipedia.org/wiki/Network_File_System) con las dos máquinas virtuales desplegadas, cuyo contenido podemos encontrar dentro de estas en la carpeta `/mnt/nfs_shares/docs`, con el fin de tener acceso tanto al proyecto demo, como al archivo adicional necesario para la ejecución del proyecto en paralelo nodes, que alberga las direcciones ips de las máquinas donde se ejecutará el proyecto demo, junto con las cpus disponibles para cada máquina. Una vez aclarado esto, se puede proceder a la ejecución del proyecto.

## Ejecución del proyecto de prueba

Para la ejecución del proyecto de prueba, se debe ingresar a la carpeta que lo alberga, ubicada a su vez, dentro de la carpeta utilizada para el sistema de archivos compartidos, a cuya ubicación podemos ingresar por medio de cualquiera de las dos máquinas desplegadas, después de haber ingresado a una de estas por medio de ssh, en la ruta `/mnt/nfs_shares/docs/smallPoolFire3D`. 

Una vez dentro de la carpeta, se deben ejecutar los siguientes comandos con el fin de preparar el proyecto para su ejecución en paralelo por medio de Open Mpi.
```bash
$ singularity exec /home/vagrant/of-7.sif blockMesh
$ singularity exec /home/vagrant/of-7.sif topoSet
$ singularity exec /home/vagrant/of-7.sif createPatch -overwrite
$ singularity exec /home/vagrant/of-7.sif decomposePar
```
Después de ejecutada la sucesión de comandos, se dispondrán dentro de la carpeta del proyecto demo, algunos archivos adicionales necesarios para la ejecución del mismo.

Ahora se debe copiar el archivo nodes, ubicado en la carpeta  `/mnt/nfs_shares/docs/`, dentro de la carpeta del proyecto demo, con el fin de ejecutar, por medio de Open Mpi, el proyecto de manera distribuida.

En este punto, el proyecto cumple con la configuración de rigor para ser ejecutado por medio de Open Mpi, esto se logra por medio del comando: 
```bash
$ mpirun --mca btl_tcp_if_include eth1 --hostfile nodes -np 4 singularity exec /home/vagrant/of-7.sif fireFoam -parallel
```

-El comando `mpirun`, ejecuta la interfaz de paso de mensajes de Open Mpi.

-La bandera `--mca`, permite al comando mpirun recibir directrices de configuración.

-La directriz `btl_tcp_if_include`, permite usar TCP para la comunicación MPI, de manera que restringe el uso de ciertas redes. Recibe como valores, una lista de nombres de interfaces de red, que en este caso se reduce a `eth1`.

-La bandera `--hostfile`, permite determinar cúal es el nombre del archivo de configuración que alberga las direcciones ips y las cpus disponibles para cada máquina, que estas representan. En este caso, el archivo de configuración es llamado `nodes`.

-La bandera `-np 4`, determina el número de cpus totales que serán dispuestas para la puesta en marcha de la ejecución del proyecto.

-La directriz, `singularity exec /home/vagrant/of-7.sif`, corresponde al proceso que será ejecutado en cada una de las máquinas, en este se trata de la puesta en marcha del contenedor de singularity que alberga la instalación de openFOAM.

-La directriz `fireFoam`, se utiliza para indicar el marco resolutorio para el tipo de proyecto que se está ejecutando.

-La bandera `-parallel`, se usa para indicar que la ejecución del proyecto, se hará en paralelo.

Una vez introducido el comando, se iniciará el proceso de ejecución del proyecto de OpenFOAM, por medio del contenedor de Singularity, utilizando Open Mpi para su ejecución de manera distribuida.
