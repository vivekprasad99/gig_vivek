package com.example.awign


import com.moengage.core.DataCenter
import com.moengage.core.MoEngage
import com.moengage.flutter.MoEInitializer
import io.flutter.app.FlutterApplication
import com.moengage.core.config.NotificationConfig
import com.example.awign.BuildConfig
import com.moengage.core.LogLevel
import com.moengage.core.config.*
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging
import com.moengage.firebase.MoEFireBaseHelper
import com.moengage.core.config.FcmConfig
import com.moengage.core.model.SdkState

class AwignApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        val moEngage: MoEngage.Builder = MoEngage.Builder(this, BuildConfig.MoEngage)
            .configureLogs(LogConfig(LogLevel.VERBOSE, false))
            .configureFcm(FcmConfig(true))
            .setDataCenter(if (BuildConfig.FLAVOR == "production") DataCenter.DATA_CENTER_3 else DataCenter.DATA_CENTER_1)
            .configureNotificationMetaData(
                NotificationConfig(
                    R.drawable.launcher_icon,
                    R.drawable.launcher_icon,
                    -1,
                    true,
                    true,
                    true
                )
            )
        MoEInitializer.initialiseDefaultInstance(applicationContext, moEngage, SdkState.ENABLED,true)
    }
}