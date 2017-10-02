#!/system/bin/sh
# Copyright (c) 2012-2013, 2016, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


BRCM_SYSTEM_NVRAM_FILE=/system/etc/wifi/bcmdhd.cal
BRCM_SYSTEM_NVRAM_VERSION_FILE=/system/etc/wifi/version.txt
BRCM_MPT_NVRAM_FILE=/mpt/wifi/brcm/nvram/bcmdhd.cal
BRCM_MPT_NVRAM_VERSION_FILE=/mpt/wifi/brcm/nvram/version.txt

BRCM_SYSTEM_STA_FW_FILE=/system/etc/firmware/fw_bcmdhd.bin
BRCM_SYSTEM_AP_FW_FILE=/system/etc/firmware/fw_bcmdhd_apsta.bin
BRCM_SYSTEM_MFG_FW_FILE=/system/etc/firmware/fw_bcmdhd_mfg.bin
BRCM_SYSTEM_FW_VERSION_FILE=/system/etc/firmware/version.txt

BRCM_MPT_STA_FW_FILE=/mpt/wifi/brcm/fw/fw_bcmdhd.bin
BRCM_MPT_AP_FW_FILE=/mpt/wifi/brcm/fw/fw_bcmdhd_apsta.bin
BRCM_MPT_MFG_FW_FILE=/mpt/wifi/brcm/fw/fw_bcmdhd_mfg.bin
BRCM_MPT_FW_VERSION_FILE=/mpt/wifi/brcm/fw/version.txt

QCOM_SYSTEM_NVRAM_FILE=/system/etc/wifi/WCNSS_qcom_wlan_nv.bin
QCOM_DATA_NVRAM_FILE=/data/misc/wifi/WCNSS_qcom_wlan_nv.bin
QCOM_DATA_INI_FILE=/system/etc/wifi/WCNSS_qcom_cfg.ini
QCOM_PRIMA_NVRAM_FILE=/system/etc/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin
QCOM_PRIMA_BOOT_NVRAM_FILE=/system/etc/firmware/wlan/prima/WCNSS_qcom_wlan_nv_boot.bin

QCOM_SYSTEM_INI_FILE=/system/etc/wifi/WCNSS_qcom_cfg.ini
QCOM_SYSTEM_NVRAM_VERSION_FILE=/system/etc/wifi/version.txt
QCOM_MPT_NVRAM_FILE=/mpt/wifi/qcom/nvram/WCNSS_qcom_wlan_nv.bin
QCOM_MPT_INI_FILE=/mpt/wifi/qcom/nvram/WCNSS_qcom_cfg.ini
QCOM_MPT_NVRAM_VERSION_FILE=/mpt/wifi/qcom/nvram/version.txt



if [ "$1" == "qcom" ]; then
    echo wifi qcom smart runtime config nvram check

    if [ -a $QCOM_MPT_NVRAM_FILE ]; then
        echo qcom nvram is updated
        if [ -a $QCOM_MPT_NVRAM_VERSION_FILE ]; then
            while read line
            do
                mpt_cal_version=$line
                echo updated nvram version $mpt_cal_version
				dec_update_cal_version=$(echo "$mpt_cal_version 10" | awk '{print $1*$2}')
				echo updated dec nvram version $dec_update_cal_version
            done < $QCOM_MPT_NVRAM_VERSION_FILE

        else
            echo qcom nvram version file does not exist
            setprop persist.lge.cal_updated 0
        fi

        if [ -a $QCOM_SYSTEM_NVRAM_VERSION_FILE ]; then
            while read line
            do
                system_cal_version=$line
                echo updated nvram version $system_cal_version
				dec_system_cal_version=$(echo "$system_cal_version 10" | awk '{print $1*$2}')
				echo updated dec system version $dec_system_cal_version
            done < $QCOM_SYSTEM_NVRAM_VERSION_FILE

        else
            setprop persist.lge.cal_updated 0
        fi

        if [ $dec_update_cal_version -gt $dec_system_cal_version ]; then
            rm -rf $QCOM_DATA_NVRAM_FILE
            rm -rf $QCOM_DATA_INI_FILE
            ln -sf $QCOM_MPT_NVRAM_FILE $QCOM_PRIMA_BOOT_NVRAM_FILE
            setprop persist.lge.cal_updated 1
        else
            setprop persist.lge.cal_updated 0
        fi

    else
        echo qcom nvram is not updated
        setprop persist.lge.cal_updated 0
    fi
fi

if [ "$1" == "brcm" ]; then
    echo wifi brcm smart runtime config nvram check
    if [ -a $BRCM_MPT_NVRAM_FILE ]; then
        echo brcn nvram is updated
        if [ -a $BRCM_MPT_NVRAM_VERSION_FILE ]; then
            while read line
            do
                mpt_cal_version=$line
                echo updated nvram version $mpt_cal_version
				dec_update_cal_version=$(echo "$mpt_cal_version 10" | awk '{print $1*$2}')
				echo updated dec nvram version $dec_update_cal_version
            done < $BRCM_MPT_NVRAM_VERSION_FILE

        else
            echo brcm nvram version file does not exist
            echo "$BRCM_SYSTEM_NVRAM_FILE" > /sys/module/bcmdhd/parameters/nvram_path
            setprop persist.lge.cal_updated 0
        fi

        if [ -a $BRCM_SYSTEM_NVRAM_VERSION_FILE ]; then
            while read line
            do
                system_cal_version=$line
                echo updated nvram version $system_cal_version
				dec_system_cal_version=$(echo "$system_cal_version 10" | awk '{print $1*$2}')
				echo updated dec system version $dec_system_cal_version
            done < $BRCM_SYSTEM_NVRAM_VERSION_FILE

        else
            echo "$BRCM_SYSTEM_NVRAM_FILE" > /sys/module/bcmdhd/parameters/nvram_path
            setprop persist.lge.cal_updated 0
        fi


        if [ $dec_update_cal_version -gt $dec_system_cal_version ]; then
            echo "$BRCM_MPT_NVRAM_FILE" > /sys/module/bcmdhd/parameters/nvram_path
            setprop persist.lge.cal_updated 1
        else
            echo "$BRCM_SYSTEM_NVRAM_FILE" > /sys/module/bcmdhd/parameters/nvram_path
            setprop persist.lge.cal_updated 0
        fi
    else
        echo qcom nvram is not updated
        echo "$BRCM_SYSTEM_NVRAM_FILE" > /sys/module/bcmdhd/parameters/nvram_path
        setprop persist.lge.cal_updated 0
    fi

    if [ -a $BRCM_MPT_STA_FW_FILE ] && [ -a $BRCM_MPT_AP_FW_FILE ] && [ -a $BRCM_MPT_MFG_FW_FILE ]; then
        echo brcn fw is updated
        if [ -a $BRCM_MPT_FW_VERSION_FILE ]; then
            while read line
            do
                mpt_fw_version=$line
                echo updated fw version $mpt_fw_version
            done < $BRCM_MPT_FW_VERSION_FILE

        else
            echo brcm fw version file does not exist
            echo "$BRCM_SYSTEM_FW_FILE" > /sys/module/bcmdhd/parameters/firmware_path
            setprop persist.lge.fw_updated 0
        fi

        if [ -a $BRCM_SYSTEM_FW_VERSION_FILE ]; then
            while read line
            do
                system_fw_version=$line
                echo updated fw version $system_fw_version
            done < $BRCM_SYSTEM_FW_VERSION_FILE

        else
            echo "$BRCM_SYSTEM_FW_FILE" > /sys/module/bcmdhd/parameters/firmware_path
            setprop persist.lge.fw_updated 0
        fi

        if [ $mpt_fw_version -gt $system_fw_version ]; then
            echo "$BRCM_MPT_FW_FILE" > /sys/module/bcmdhd/parameters/firmware_path
            setprop persist.lge.fw_updated 1
        else
            echo "$BRCM_SYSTEM_FW_FILE" > /sys/module/bcmdhd/parameters/firmware_path
            setprop persist.lge.fw_updated 0
        fi
    else
        echo qcom nvram is not updated
        echo "$BRCM_SYSTEM_FW_FILE" > /sys/module/bcmdhd/parameters/firmware_path
        setprop persist.lge.fw_updated 0
    fi

fi
