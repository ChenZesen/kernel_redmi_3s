#!/bin/bash

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#### USAGE:
#### ./build_kernel.sh [clean]
#### [clean] - clean is optional
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#####
### Prepared by:
### Prema Chand Alugu (premaca@gmail.com)
#####
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

### This is INLINE_KERNEL_COMPILATION

### Create a directory, and keep kernel code, example:
#### premaca@paluguUB:~/KERNEL_COMPILE$ ls
####    aarch64-linux-android-4.9 kernel-code
####

JERRICA_POSTFIX=$(date +"%Y%m%d")

## platform specifics
export ARCH=arm64
export SUBARCH=arm64
TOOL_CHAIN_ARM=aarch64-linux-android-

#@@@@@@@@@@@@@@@@@@@@@@ DEFINITIONS BEGIN @@@@@@@@@@@@@@@@@@@@@@@@@@@#
##### Tool-chain, you should get it yourself which tool-chain 
##### you would like to use
KERNEL_TOOLCHAIN=/home/premaca/device_repos/aarch64-linux-android-4.9/bin/$TOOL_CHAIN_ARM

## This script should be inside the kernel-code directory
KERNEL_DIR=$PWD

## should be preset in arch/arm64/configs of kernel-code
KERNEL_DEFCONFIG=land_kernel_defconfig

## make jobs
MAKE_JOBS=10

## Give the path to the toolchain directory that you want kernel to compile with
## Not necessarily to be in the directory where kernel code is present
export CROSS_COMPILE=$KERNEL_TOOLCHAIN
#@@@@@@@@@@@@@@@@@@@@@@ DEFINITIONS  END  @@@@@@@@@@@@@@@@@@@@@@@@@@@#


# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    clean)
    CLEAN_BUILD=YES
    #shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

## command execution function, which exits if some command execution failed
function exec_command {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "********************************" >&2
        echo "!! FAIL !! executing command $1" >&2
        echo "********************************" >&2
        exit
    fi
    return $status
}

echo "***** Tool chain is set to $KERNEL_TOOLCHAIN *****"
echo "***** Kernel defconfig is set to $KERNEL_DEFCONFIG *****"
exec_command make $KERNEL_DEFCONFIG

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Read [clean]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
if [ "$CLEAN_BUILD" == 'YES' ]
        then echo;
        echo "***************************************************************"
        echo "***************!!!!!  BUILDING CLEAN  !!!!!********************"
        echo "***************************************************************"
        echo;
        exec_command make clean
        exec_command make mrproper
        make ARCH=$ARCH CROSS_COMPILE=$TOOL_CHAIN_ARM  $KERNEL_DEFCONFIG
fi


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Do the JOB, make it
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
## you can tune the job number depends on the cores
exec_command make -j$MAKE_JOBS


exec_command cd $KERNEL_DIR

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"
echo "##    Please Scroll up and verify for any Errors        ##"
echo "##    Script exiting Successfully !!                    ##"
echo "##                                                      ##"
echo "##     KERNEL BUILD IS SUCCESSFUL                       ##"
echo "##                                                      ##"
echo "##                                                      ##"
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"

exit

