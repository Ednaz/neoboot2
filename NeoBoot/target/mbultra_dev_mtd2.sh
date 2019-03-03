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
                        if [ $BOXNAME = "mbultra" ] || [ $CHIPSET = "bcm7424" ]; then 
                            if [ -f /proc/stb/info/boxtype ]; then 
                                if [ -e $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz ] ; then
                                    echo "Kasowanie kernel z /dev/mtd2..."                                    
                                    flash_erase /dev/mtd2 
                                    sleep 2 
                                    echo "Instalacja kernel do /dev/mtd2..."                
                		    nandwrite -p /dev/mtd2 $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz 
                                    update-alternatives --remove vmlinux vmlinux-$KERNEL || true
                                fi                           
                            fi
                        fi
                        update-alternatives --remove vmlinux vmlinux-`uname -r` || true                                          
                        echo "NEOBOOT is booting image from " $TARGET
                        echo "Used Kernel: " $TARGET > $NEOBOOTMOUNT/ImagesUpload/.kernel/used_flash_kernel                          

                elif [ ! -e /.multinfo ]; then                                                  
                            if [ $BOXNAME = "mbultra" ] || [ $CHIPSET = "bcm7424" ]; then 
                                if [ -e $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz ] ; then
                                    echo "Kasowanie kernel z /dev/mtd2..."
                                    sleep 2                                
                                    flash_eraseall /dev/mtd2    
                                    echo "Wgrywanie kernel do /dev/mtd2..."
                                    sleep 2                                                    
		                    nandwrite -p /dev/mtd2 $NEOBOOTMOUNT/ImagesUpload/.kernel/vmlinux.gz 
                                    update-alternatives --remove vmlinux vmlinux-$KERNEL || true
                                fi                            
                            fi                            
                fi
                echo " NEOBOOT Start sytem - " $TARGET  "Za chwile nastapi restart !!!"
                echo "Used Kernel: " $TARGET   > $NEOBOOTMOUNT/ImagesUpload/.kernel/used_flash_kernel
                sleep 5; reboot -d -f -h -i
else              	    
    if [ $TARGET != "Flash" ]; then                       
        if [ $BOXNAME = "mbultra" ] || [ $CHIPSET = "bcm7424" ]; then	     
                        if [ -e /.multinfo ] ; then
                                INFOBOOT=$( cat /.multinfo )
                                if [ $TARGET = $INFOBOOT ] ; then
                                    echo "NEOBOOT is booting image from " $TARGET                                    
                                else                                  
                                    echo "Przenoszenie pliku kernel do /tmp"
                                    sleep 2
                                    cp -f $NEOBOOTMOUNT$IMAGE/$TARGET/boot/$BOXNAME.vmlinux.gz /tmp/vmlinux.gz 
                                    echo "Kasowanie kernel z /dev/mtd2"
                                    sleep 2 
                                    flash_eraseall /dev/mtd2 
                                    echo "Wgrywanie kernel do /dev/mtd2"                                    
                                    sleep 2
		                    nandwrite -p /dev/mtd2 //tmp/vmlinux.gz 
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
                                    echo "Kasowanie kernel z /dev/mtd2"
                                    sleep 2                                    
                                    flash_eraseall /dev/mtd2  
                                    echo "Wgrywanie kernel do /dev/mtd2"                                    
                                    sleep 2                                                                       
		                    nandwrite -p /dev/mtd2 /tmp/vmlinux.gz 
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
