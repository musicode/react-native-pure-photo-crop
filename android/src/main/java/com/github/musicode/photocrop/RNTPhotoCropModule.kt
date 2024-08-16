package com.github.musicode.photocrop

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.github.herokotlin.photocrop.PhotoCropActivity
import com.github.herokotlin.photocrop.PhotoCropCallback
import com.github.herokotlin.photocrop.PhotoCropConfiguration
import com.github.herokotlin.photocrop.model.CropFile

class RNTPhotoCropModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    companion object {

        fun init(loader: (Context, String, (Bitmap?) -> Unit) -> Unit) {
            PhotoCropActivity.loadImage = loader
        }

    }

    override fun getName(): String {
        return "RNTPhotoCrop"
    }

    @ReactMethod
    fun open(options: ReadableMap, promise: Promise) {

        val configuration = object : PhotoCropConfiguration() {}

        configuration.cropWidth = options.getInt("width").toFloat()
        configuration.cropHeight = options.getInt("height").toFloat()

        if (options.hasKey("guideLabelTitle")) {
            configuration.guideLabelTitle = options.getString("guideLabelTitle")!!
        }
        if (options.hasKey("cancelButtonTitle")) {
            configuration.cancelButtonTitle = options.getString("cancelButtonTitle")!!
        }
        if (options.hasKey("resetButtonTitle")) {
            configuration.resetButtonTitle = options.getString("resetButtonTitle")!!
        }
        if (options.hasKey("submitButtonTitle")) {
            configuration.submitButtonTitle = options.getString("submitButtonTitle")!!
        }

        val callback = object : PhotoCropCallback {

            override fun onCancel(activity: Activity) {
                activity.finish()
                promise.reject("-1", "cancel")
            }

            override fun onExit(activity: Activity) {
                promise.reject("-1", "exit")
            }

            override fun onSubmit(activity: Activity, cropFile: CropFile) {
                activity.finish()

                val map = Arguments.createMap()
                map.putString("path", cropFile.path)
                map.putInt("size", cropFile.size.toInt())
                map.putInt("width", cropFile.width)
                map.putInt("height", cropFile.height)

                promise.resolve(map)
            }

        }

        PhotoCropActivity.configuration = configuration
        PhotoCropActivity.callback = callback

        PhotoCropActivity.newInstance(currentActivity!!, options.getString("url")!!)

    }

}
