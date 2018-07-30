#!/bin/bash
BOOT ()
{
  A=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
  while [[ $A != "1" ]]; do
          sleep 1;
          A=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
  done;
}

Get_Google_Play_Services ()
{
  wget "https://www.apklinker.com/wp-content/uploads/uploaded_apk/5b51570a214a8/com.google.android.gms_12.8.74-040700-204998136_12874026_MinAPI23_(x86)(nodpi)_apklinker.com.apk"
}

Update_Google_Play_Services ()
{
  adb install -r "$PWD/com.google.android.gms_12.8.74-040700-204998136_12874026_MinAPI23_(x86)(nodpi)_apklinker.com.apk"
}
Disable_animations ()
{
  # this is for demonstration what other amazing staff can be done here
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
}
BOOT
Get_Google_Play_Services
Update_Google_Play_Services
Disable_animations
