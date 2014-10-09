#!/bin/sh

clear
root=`pwd`

#get the Xcode version, as the Simulator folder is in different locations on 5.x and 6.x
kMDItemVersion1=`mdls -name kMDItemVersion /Applications/Xcode.app`
kMDItemVersion2=`echo $kMDItemVersion1 | awk -F'"' '{ print $2 }'`
kMDItemVersion=`echo $kMDItemVersion2 | cut -d'.' -f 1`

#arrays to display a list of available simulators and their directory paths
available_devices_display=()
available_devices_id=()
available_devices_path=()
available_devices_ios_version=()

if [ $kMDItemVersion -eq 6 ]; then
	cd ~/Library/Developer/CoreSimulator/Devices/
	array=($(ls -d -t */))
	tLen=${#array[@]}
	for (( i=0; i<${tLen}; i++ ));
	do
	  	sub_dir="${array[$i]}"
		cd $sub_dir
		name=`/usr/libexec/PlistBuddy -c "print :name" device.plist`
		runtime1=`/usr/libexec/PlistBuddy -c "print :runtime" device.plist`
		runtime2=`echo $runtime1| cut -d'.' -f 5`
		runtime3=`echo ${runtime2//iOS-/"iOS "}`
		runtime=`echo ${runtime3//-/"."}`
	   	available_device_display="$name, $runtime"

		version1=`echo ${runtime2//iOS-/""}`
		version2=`echo ${version1//-/"."}`
		version=`echo $version2 | cut -d'.' -f 1`

		available_devices_display+=("$available_device_display")
		echo "$available_device_display"
		available_devices_id+=("$name")
		available_devices_path+=(`pwd`)
		available_devices_ios_version+=("$version")
		cd ..
	done

	cd "$root"
	CD="CocoaDialog.app/Contents/MacOS/CocoaDialog"

	rv=`$CD standard-dropdown --icon "find" --title "Where's my Simulator" --text "This script opens the documents directory of the last run simulator in Xcode. The options are sorted in last updated device/iOS. Which simulator are you looking for?" --button1 "Ok" --exit‑onchange --float --items "${available_devices_display[@]}"`
	did_cancel=`echo $rv | awk '{print$1}'`
	echo "did_cancel: $did_cancel"
	if [ $did_cancel -eq 2 ]; then
		exit 0
	fi
	index=`echo $rv | cut -d' ' -f2-`

	temp2=${available_devices_display[$index]}
	$CD bubble --title "Where's my Simulator" --timeout 1 --x-placement "center" --y-placement "center" --text "Opening Simulator for $temp2"

	temp1=${available_devices_path[$index]}
	temp2=${available_devices_ios_version[$index]}

	echo "temp2: $temp2"

	if [ $temp2 == "8" ]; then
		temp3="$temp1/data/Containers/Data/Application"
	else
		temp3="$temp1/data/Applications"
	fi

	echo "temp3: $temp3"

	if [ -d "$temp3" ]; then
		cd $temp3
		array=($(ls -d -t */))
		sub_dir="${array[0]}"
		temp=`open "$sub_dir"`
	else
		$CD bubble --title "Where's my Simulator" --timeout 1 --x-placement "center" --y-placement "center" --text "Application Folder not found"
		temp=`open "$temp1/data"`
	fi
else
	cd ~
	cd "Library/Application Support/iPhone Simulator"
	array=($(ls -d -t */))
	tLen=${#array[@]}
	for (( i=0; i<${tLen}; i++ ));
	do
	  	sub_dir="${array[$i]}"
		cd $sub_dir
		temp=${sub_dir%/}
		available_devices_display+=("$temp")
		available_devices_id+=("$temp")
		available_devices_path+=("`pwd`")
		cd ..
	done

	cd "$root"
	CD="CocoaDialog.app/Contents/MacOS/CocoaDialog"

	rv=`$CD standard-dropdown --icon "find" --title "Where's my Simulator" --text "This script opens the documents directory of the last run simulator in Xcode. The options are sorted in last updated device/iOS. Which simulator are you looking for?" --button1 "Ok" --exit‑onchange --float --items "${available_devices_display[@]}"`
	did_cancel=`echo $rv | awk '{print$1}'`
	if [ $did_cancel -eq 2 ]; then
		exit 0
	fi
	index=`echo $rv | cut -d' ' -f2-`

	temp2=${available_devices_display[$index]}
	$CD bubble --title "Where's my Simulator" --timeout 1 --x-placement "center" --y-placement "center" --text "Opening Simulator for iOS $temp2"

	temp1=${available_devices_path[$index]}
	echo "temp1 $temp1"
	temp3="$temp1/Applications"
	echo "temp3 $temp3"

	if [ -d "$temp3" ]; then
		cd "$temp3"
		array=($(ls -d -t */))
		sub_dir="${array[0]}"
		temp=`open "$sub_dir"`
	else
		$CD bubble --title "Where's my Simulator" --timeout 1 --x-placement "center" --y-placement "center" --text "Application Folder not found"
		temp=`open "$temp1"`
	fi
fi