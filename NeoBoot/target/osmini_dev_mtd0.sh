#!/bin/sh
#script - gutosie 
 

if [ -f /proc/stb/info/vumodel ];  then  
    VUMODEL=$( cat /proc/stb/info/vumodel )     
fi 

if [ -f /proc/stb/info/boxtype ];  then  
    BOXTYPE=$( cat /proc/stb/info/boxtype )    
fi

if [ -f /proc/stb/info/chipset ];  then  
    CHIPSET=$( cat /proc/stb/info/chipset )    
fi

if [ -f /tmp/zImage.ipk ];  then  
    rm -f /tmp/zImage.ipk    
fi

if [ -f /tmp/zImage ];  then  
    rm -f /tmp/zImage    
fi

KERNEL=`uname -r` 
IMAGE=ImageBoot
IMAGENEXTBOOT=/ImageBoot/.neonextboot
NEOBOOTMOUNT=$( cat /usr/lib/enigma2/python/Plugins/Extensions/NeoBoot/.location) 
BOXNAME=$( cat /etc/hostname) 
# $NEOBOOTMOUNT$IMAGE 
# $NEOBOOTMOUNT

if [ -f $NEOBOOTMOUNT$IMAGENEXTBOOT ]; then
  TARGET=`cat $NEOBOOTMOUNT$IMAGENEXTBOOT`
else
  TARGET=Flash              
fi
                  
if [ $TARGET = "Flash" ]; then                    
                if [ -e /.multinfo ]; then                                                
                        if [ $BOXNAME = "osmini" ] || [ $CHIPSET = "BCM7362" ]  || [ $BOXNAME = "osmini" ]; then 
                                if [ -e $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz ] ; then
                                    echo "Kasowanie kernel z /dev/mtd0..."                                    
                                    flash_eraseall /dev/mtd0 
                                    sleep 2 
                                    echo "Instalacja kernel do /dev/mtd0..."                
		                    nandwrite -p /dev/mtd0 $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz 
                                    update-alternatives --remove vmlinux vmlinux-$KERNEL || true
                                fi                                                     
                        fi
                        update-alternatives --remove vmlinux vmlinux-`uname -r` || true                                          
                        echo "NEOBOOT is booting image from " $TARGET
                        echo "Used Kernel: " $TARGET > $NEOBOOTMOUNT/ImagesUpload/.kernel/used_flash_kernel
                        sleep 5; reboot -d -f -h -i                           

                elif [ ! -e /.multinfo ]; then
                            if [ $BOXNAME = "osmini" ] || [ $CHIPSET = "BCM7362" ]; then
                                if [ -e $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz ] ; then
                                    echo "Kasowanie kernel z /dev/mtd0..."
                                    sleep 2                                
                                    flash_eraseall /dev/mtd0   
                                    echo "Wgrywanie kernel do /dev/mtd0..."
                                    sleep 2                                                    
		                    nandwrite -p /dev/mtd0 $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz 
                                    update-alternatives --remove vmlinux vmlinux-$KERNEL || true
                                fi                                                                                                               
                            fi                            
                            update-alternatives --remove vmlinux vmlinux-`uname -r` || true
                            echo "Used Kernel: " $TARGET > $NEOBOOTMOUNT/ImagesUpload/.kernel/used_flash_kernel
                            echo " NEOBOOT - zainstalowano kernel-image - " $TARGET  "Za chwile nastapi restart systemu !!!"
                            sleep 5 ; reboot -d -f -h -i
                fi
else              	    
    if [ $TARGET != "Flash" ]; then 	     
        if [ $BOXNAME = "osmini" ] || [ $CHIPSET = "BCM7362" ] ; then
                        if [ -e /.multinfo ] ; then
                                INFOBOOT=$( cat /.multinfo )
                                if [ $TARGET = $INFOBOOT ] ; then
                                    echo "NEOBOOT is booting image from " $TARGET                                    
                                else                                  
                                    echo "Przenoszenie pliku kernel do /tmp"
                                    sleep 2
                                    cp -f $NEOBOOTMOUNT$IMAGE/$TARGET/boot/$BOXNAME.vmlinux.gz /tmp/vmlinux.gz 
                                    echo "Kasowanie kernel z /dev/mtd0"
                                    sleep 2 
                                    flash_eraseall /dev/mtd0
                                    echo "Wgrywanie kernel do /dev/mtd0"                                    
                                    sleep 2
		                    nandwrite -p /dev/mtd0 //tmp/vmlinux.gz 
		                    rm -f //tmp/vmlinux.gz
                                    update-alternatives --remove vmlinux vmlinux-`uname -r` || true
                                    echo "Kernel dla potrzeb startu systemu " $TARGET " z procesorem mips zostal zmieniony!!!"
                                    echo "Used Kernel: " $TARGET   > $NEOBOOTMOUNT/ImagesUpload/.kernel/used_flash_kernel
                                    echo "Typ procesora: " $CHIPSET " STB" 
                                fi
                        else
                                    echo "Przenoszenie pliku kernel do /tmp"
                                    sleep 2
                                    cp -f $NEOBOOTMOUNT$IMAGE/$TARGET/boot/$BOXNAME.vmlinux.gz /tmp/vmlinux.gz
                                    echo "Kasowanie kernel z /dev/mtd0"
                                    sleep 2                                    
                                    flash_eraseall /dev/mtd0 
                                    echo "Wgrywanie kernel do /dev/mtd0"                                    
                                    sleep 2                                                                       
		                    nandwrite -p /dev/mtd0 /tmp/vmlinux.gz 
		                    rm -f /tmp/vmlinux.gz
                                    update-alternatives --remove vmlinux vmlinux-`uname -r` || true
                                    echo "Kernel dla potrzeb startu systemu " $TARGET " z procesorem mips zostal zmieniony!!!"
                                    echo "Used Kernel: " $TARGET   > $NEOBOOTMOUNT/ImagesUpload/.kernel/used_flash_kernel
                                    echo "Typ procesora: " $CHIPSET " STB"
                        fi                
                        sleep 5; reboot -d -f -h -i
        fi
    fi                               
fi
exit 0
