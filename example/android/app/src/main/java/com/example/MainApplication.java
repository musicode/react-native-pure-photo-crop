package com.example;

import android.app.Application;
import android.content.Context;
import android.graphics.Bitmap;
import android.support.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.github.musicode.photocrop.RNTPhotoCropModule;
import com.github.musicode.photocrop.RNTPhotoCropPackage;

import java.util.Arrays;
import java.util.List;

import kotlin.jvm.functions.Function1;
import kotlin.jvm.functions.Function3;

public class MainApplication extends Application implements ReactApplication {

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
          new RNTPhotoCropPackage()
      );
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    SoLoader.init(this, /* native exopackage */ false);

    RNTPhotoCropModule.setImageLoader(
            new Function3() {
              @Override
              public Object invoke(Object o1, Object o2, Object o3) {
                Context context = (Context)o1;
                String url = (String)o2;
                final Function1 onComplete = (Function1)o3;

                Glide.with(context).asBitmap().load(url).listener(new RequestListener<Bitmap>() {
                  @Override
                  public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                    onComplete.invoke(null);
                    return false;
                  }

                  @Override
                  public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                    onComplete.invoke(resource);
                    return false;
                  }
                }).preload();

                return null;
              }
            }
    );

  }
}
