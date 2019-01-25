package com.github.musicode.photocrop;

import android.app.Activity;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.github.herokotlin.photocrop.PhotoCropActivity;
import com.github.herokotlin.photocrop.PhotoCropCallback;
import com.github.herokotlin.photocrop.PhotoCropConfiguration;
import com.github.herokotlin.photocrop.model.CropFile;
import com.github.herokotlin.photocrop.util.Compressor;

import kotlin.jvm.functions.Function3;

public class RNTPhotoCropModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public RNTPhotoCropModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    public static void setImageLoader(Function3 loader) {
        PhotoCropActivity.Companion.setLoadImage(loader);
    }

    @Override
    public String getName() {
        return "RNTPhotoCrop";
    }

    @ReactMethod
    public void open(String url, int width, int height, final Promise promise) {

        PhotoCropConfiguration configuration = new PhotoCropConfiguration() {};
        configuration.setCropWidth(width);
        configuration.setCropHeight(height);

        PhotoCropCallback callback = new PhotoCropCallback() {
            @Override
            public void onCancel(Activity activity) {
                activity.finish();
                promise.reject("-1", "cancel");
            }

            @Override
            public void onSubmit(Activity activity, CropFile cropFile) {
                activity.finish();

                WritableMap map = Arguments.createMap();
                map.putString("path", cropFile.getPath());
                map.putInt("size", (int)cropFile.getSize());
                map.putInt("width", cropFile.getWidth());
                map.putInt("height", cropFile.getHeight());

                promise.resolve(map);
            }
        };

        PhotoCropActivity.Companion.setConfiguration(configuration);
        PhotoCropActivity.Companion.setCallback(callback);

        PhotoCropActivity.Companion.newInstance(reactContext.getCurrentActivity(), url);

    }

    @ReactMethod
    public void compress(String path, int size, int width, int height, int maxSize, int maxWith, int maxHeight, float quality, Promise promise) {

        CropFile file = new CropFile(path, size, width, height);

        Compressor compressor = new Compressor(maxWith, maxHeight, maxSize, quality);
        CropFile result = compressor.compress(reactContext.getCurrentActivity(), file);

        WritableMap map = Arguments.createMap();
        map.putString("path", result.getPath());
        map.putInt("size", (int)result.getSize());
        map.putInt("width", result.getWidth());
        map.putInt("height", result.getHeight());

        promise.resolve(result);

    }

}