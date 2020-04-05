package com.github.musicode.photocrop

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import com.facebook.react.ReactActivity

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.modules.core.PermissionAwareActivity
import com.github.herokotlin.permission.Permission
import com.github.herokotlin.photocrop.PhotoCropActivity
import com.github.herokotlin.photocrop.PhotoCropCallback
import com.github.herokotlin.photocrop.PhotoCropConfiguration
import com.github.herokotlin.photocrop.model.CropFile
import com.github.herokotlin.photocrop.util.Compressor

class RNTPhotoCropModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    companion object {

        private val permission = Permission(19901, listOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE))

        fun setImageLoader(loader: (Context, String, (Bitmap?) -> Unit) -> Unit) {
            PhotoCropActivity.loadImage = loader
        }

    }

    override fun getName(): String {
        return "RNTPhotoCrop"
    }

    private var permissionListener = { requestCode: Int, permissions: Array<out String>?, grantResults: IntArray? ->
        if (permissions != null && grantResults != null) {
            permission.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
        true
    }

    @ReactMethod
    fun open(options: ReadableMap, promise: Promise) {

        permission.onExternalStorageNotWritable = {
            promise.reject("3", "external storage is not writable.")
        }

        permission.onPermissionsDenied = {
            promise.reject("2", "you denied the requested permissions.")
        }

        permission.onPermissionsNotGranted = {
            promise.reject("1", "has no permissions.")
        }

        permission.onRequestPermissions = { activity, list, requestCode ->
            if (activity is ReactActivity) {
                activity.requestPermissions(list, requestCode, permissionListener)
            }
            else if (activity is PermissionAwareActivity) {
                (activity as PermissionAwareActivity).requestPermissions(list, requestCode, permissionListener)
            }
        }

        if (permission.checkExternalStorageWritable()) {
            permission.requestPermissions(currentActivity!!) {
                openActivity(options, promise)
            }
        }

    }

    private fun openActivity(options: ReadableMap, promise: Promise) {

        val configuration = object : PhotoCropConfiguration() {}

        configuration.cropWidth = options.getInt("width").toFloat()
        configuration.cropHeight = options.getInt("height").toFloat()

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

    @ReactMethod
    fun compress(options: ReadableMap, promise: Promise) {

        val file = CropFile(
            options.getString("path")!!,
            options.getInt("size").toLong(),
            options.getInt("width"),
            options.getInt("height")
        )

        val compressor = Compressor(
            options.getInt("maxWidth"),
            options.getInt("maxHeight"),
            options.getInt("maxSize"),
            options.getDouble("quality").toFloat()
        )

        val cacheDir = reactContext.externalCacheDir
        if (cacheDir == null) {
            promise.reject("1", "getExternalCacheDir() is null.")
            return
        }

        val imageDir = cacheDir.absolutePath

        val handler = Handler(Looper.getMainLooper())

        Thread(Runnable {
            val (path, size, width, height) = compressor.compress(imageDir, file)

            val map = Arguments.createMap()
            map.putString("path", path)
            map.putInt("size", size.toInt())
            map.putInt("width", width)
            map.putInt("height", height)

            handler.post { promise.resolve(map) }
        }).start()

    }

}