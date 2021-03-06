#!/bin/bash
# The main intention is to roll back to the previous working kernel
# We do this by altering the grub configuration

# From the man page
# Set the default boot menu entry for GRUB.  This requires setting GRUB_DEFAULT=saved in /etc/default/grub
set_grub_default() {
        # if not set to saved, replace it
        sed -i "s/GRUB_DEFAULT=[[:digit:]]/GRUB_DEFAULT=saved/" /etc/default/grub
}

# set the default kernel accordingly
# This is different for RedHat and Ubuntu/SUSE distros
# Ubuntu and SLES use sub-menues

# the variables are defined in base.sh
if [[ $isRedHat == "true" ]]; then
        if [[ $isRedHat6 == "true" ]]; then
                grubby --set-default=1 # This is the previous kernel
                ldconfig
        else
                set_grub_default
                grubby --set-default=1 # This is the previous kernel

                if [[ $(grep -qe 'VERSION_ID=\"7.\?[1-9]\?\"' /etc/os-release) ]]; then
                        grub2-mkconfig -o /boot/grub2/grub.cfg
                fi
                
                # Exception for RedHat 8.0 i.e sku RedHat:RHEL-HA:8.0:8.0.2020021914
                # here we don't have to run the patch operation
                if [[ $(grep -qe 'VERSION_ID="8\.0"' /etc/os-release) -eq 0 ]]; then
                        grub2-mkconfig -o /boot/grub2/grub.cfg
                fi

                # Fix for a bug in RedHat 8.1/8.2
                # https://bugzilla.redhat.com/show_bug.cgi?id=1850193
                # This needs to be fixed as soon as the bug with grub2-mkconfig is solved too
                if [[ ($(grep -qe 'ID="rhel"' /etc/os-release) -eq 0) && ($(grep -qe 'VERSION_ID=\"8.\?[1-2]\?\"' /etc/os-release) -eq 0) ]]; then 
                        # no bug with UEFI
                        if [[ -d /sys/firmware/efi ]]; then 
                                grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
                        else

cat > /boot/grub2/grub-cfg.patch <<EOF
11,12c
if [ -f (hd0,gpt15)/efi/redhat/grubenv ]; then
load_env -f (hd0,gpt15)/efi/redhat/grubenv
.
EOF
grub2-mkconfig -o /boot/grub2/grub.cfg

                                # Need to handle the condition where grubenv is a softlink
                                # This needs to be fixed if the new grub2 for redhat is available -->  https://bugzilla.redhat.com/show_bug.cgi?id=1850193
                                if [[ -L /boot/grub2/grubenv ]]; then
                                        yum install -y patch
                                        patch /boot/grub2/grub.cfg /boot/grub2/grub-cfg.patch
                                fi

                                # These lines are required as we have the ld.so.cache not build correct
                                # Otherwise this can lead in no functional network afterwards
                                # TODO find a better solution and the root cause for it
                                mv /sbin/dhclient /sbin/dhclient.org
cat > /sbin/dhclient <<EOF
#!/bin/bash
# This script got created by linux-alar-fki
# in order to fix an ld.so.cache issue that does the dhclient not to work properly
ldconfig
/sbin/dhclient.org
EOF
chmod 755 /sbin/dhclient
                        fi
                fi
        fi

        # enable sysreq
        echo "kernel.sysrq = 1" >> /etc/sysctl.conf
fi

if [[ $isUbuntu == "true" ]]; then
        set_grub_default
        sed -i -e 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="1>2"/' /etc/default/grub
        update-grub
fi

if [[ $isSuse == "true" ]]; then
        set_grub_default
        sed -i -e 's/GRUB_DEFAULT=.*/GRUB_DEFAULT="1>2"/' /etc/default/grub
        grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# For reference --> https://www.linuxsecrets.com/2815-grub2-submenu-change-boot-order

