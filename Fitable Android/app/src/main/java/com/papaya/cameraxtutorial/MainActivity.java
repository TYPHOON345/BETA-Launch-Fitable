package com.papaya.cameraxtutorial;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import androidx.lifecycle.LifecycleOwner;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Camera;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.media.Image;
import android.os.Build;
import android.os.Bundle;
import android.os.Debug;
import android.preference.Preference;
import android.util.Log;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.Surface;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.gms.common.util.SharedPreferencesUtils;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseDetection;
import com.google.mlkit.vision.pose.PoseDetector;
import com.google.mlkit.vision.pose.PoseLandmark;
import com.google.mlkit.vision.pose.defaults.PoseDetectorOptions;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;

public class MainActivity extends AppCompatActivity {

    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;
    private List<PoseLandmark> allPoseLandmarks;
    PreviewView previewView;
    private ImageAnalysis imageAnalysis;
    private RelativeLayout relativeLayout;
    RepCounter repCounter;
    ImageView imgView;
    TextView repView;
    Button startBtn;
    Button backBtn;
    Button resetBtn;
    boolean wasDown;
    boolean isStart = false;
    Float height;
    String exerciseCountHead;

    DrawView canvasView;
    private PoseDetector poseDetector;
    int Scr_w;
    int Scr_h;


    //creates initial app view
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        hideSystemBars();
        setContentView(R.layout.activity_main);


        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, 100);
        }

        relativeLayout = findViewById(R.id.relativeLayout);
        canvasView = new DrawView(this);
        relativeLayout.addView(canvasView);

        imgView = findViewById(R.id.imgView);
        imgView.setRotation(-90f);

        repView = findViewById(R.id.repCounter);

        Intent intent = getIntent();
        String exercise = intent.getStringExtra("exercise");
        repCounter = new RepCounter(exercise);
        if (exercise.equals("squats")) {
            exerciseCountHead = "Squats: ";
        } else if (exercise.equals("lunges")) {
            exerciseCountHead = "Lunges: ";
        }
        repView.setText(exerciseCountHead + "0");





        Scr_w = (int) Resources.getSystem().getDisplayMetrics().widthPixels;
        Scr_h = (int) Resources.getSystem().getDisplayMetrics().heightPixels;

        getSupportActionBar().hide();

        //previewView = findViewById(R.id.previewView);


        PoseDetectorOptions options = new PoseDetectorOptions.Builder()
                .setDetectorMode(PoseDetectorOptions.STREAM_MODE)
                .build();
        poseDetector = PoseDetection.getClient(options);

        cameraProviderFuture = ProcessCameraProvider.getInstance(this);
        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                startCameraX(cameraProvider);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
        }, getExecutor());


       startBtn = findViewById(R.id.startBtn);
       startBtn.setOnClickListener(new View.OnClickListener() {
           @Override
           public void onClick(View view) {
               if (isStart) {
                   isStart = false;
                   startBtn.setText("START");
               } else {
                   //isStart = true;
                   startBtn.setText("STOP");
                   isStart = true;
               }
           }
       });

       backBtn = findViewById(R.id.backBtn);
       backBtn.setOnClickListener(new View.OnClickListener() {
           @Override
           public void onClick(View view) {
               finish();
           }
       });

       resetBtn = findViewById(R.id.resetBtn);
       resetBtn.setOnClickListener(new View.OnClickListener() {
           @Override
           public void onClick(View view) {
               repCounter.setReps(0);
               repView.setText(exerciseCountHead + String.valueOf(repCounter.getReps()));
           }
       });
    }


    private Executor getExecutor() {
        return ContextCompat.getMainExecutor(this);
    }

    private void startCameraX(ProcessCameraProvider cameraProvider) {
        cameraProvider.unbindAll();

        CameraSelector cameraSelector = new CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_FRONT)
                .build();


        Preview preview = new Preview.Builder().build();

        imageAnalysis = new ImageAnalysis.Builder()
                .setTargetResolution(new Size(imgView.getWidth(), imgView.getHeight()))
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build();
        imageAnalysis.setAnalyzer(getExecutor(), new ImageAnalysis.Analyzer() {
            @Override
            public void analyze(@NonNull ImageProxy image) {
                if (image != null) {
                    Matrix matrix = new Matrix();
                    matrix.postRotate(0f);
                    matrix.preScale(1.0f, -1.0f);
                    Bitmap bitmap = Bitmap.createBitmap(toBitmap(image.getImage()), 0, 0, image.getWidth(), image.getHeight(), matrix, true);
                    InputImage inputImage = InputImage.fromBitmap(bitmap, image.getImageInfo().getRotationDegrees());
                    imgView.setImageBitmap(bitmap);
                    Task<Pose> result = poseDetector.process(inputImage).addOnSuccessListener(
                            new OnSuccessListener<Pose>() {
                                @Override
                                public void onSuccess(@NonNull Pose pose) {
                                    //get skeletal landmarks
                                    allPoseLandmarks = pose.getAllPoseLandmarks();
                                    canvasView.DrawPose(allPoseLandmarks, imgView.getWidth(), imgView.getHeight(), imgView.getLeft(), imgView.getTop());
                                    if (isStart) {
                                        if (height == null) {
                                            height = allPoseLandmarks.get(PoseLandmark.LEFT_SHOULDER).getPosition().y - allPoseLandmarks.get(PoseLandmark.LEFT_ANKLE).getPosition().y;
                                        }
                                        String pos = repCounter.checkPose(allPoseLandmarks, height);
                                        if (pos == "up" && wasDown) {
                                            repCounter.setReps(repCounter.getReps() + 1);
                                            repView.setText(exerciseCountHead + String.valueOf(repCounter.getReps()));
                                            wasDown = false;
                                        } else if (pos == "down" && wasDown == false) {
                                            wasDown = true;
                                        }
                                    }
                                }
                            }
                    ).addOnFailureListener(
                            new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {

                                }
                            }
                    ).addOnCompleteListener(new OnCompleteListener<Pose>() {
                        @Override
                        public void onComplete(@NonNull Task<Pose> task) {
                            image.close();
                        }
                    });
                }
            }
        });

        //hello
        //preview.setSurfaceProvider(previewView.getSurfaceProvider());


        //cameraProvider.bindToLifecycle((LifecycleOwner) this, cameraSelector, preview, imageAnalysis);
        cameraProvider.bindToLifecycle((LifecycleOwner) this, cameraSelector, imageAnalysis);

    }

    private Bitmap toBitmap(Image image) {
        Image.Plane[] planes = image.getPlanes();
        ByteBuffer yBuffer = planes[0].getBuffer();
        ByteBuffer uBuffer = planes[1].getBuffer();
        ByteBuffer vBuffer = planes[2].getBuffer();

        int ySize = yBuffer.remaining();
        int uSize = uBuffer.remaining();
        int vSize = vBuffer.remaining();

        byte[] nv21 = new byte[ySize + uSize + vSize];
        //U and V are swapped
        yBuffer.get(nv21, 0, ySize);
        vBuffer.get(nv21, ySize, vSize);
        uBuffer.get(nv21, ySize + vSize, uSize);

        YuvImage yuvImage = new YuvImage(nv21, ImageFormat.NV21, image.getWidth(), image.getHeight(), null);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        yuvImage.compressToJpeg(new Rect(0, 0, yuvImage.getWidth(), yuvImage.getHeight()), 75, out);

        byte[] imageBytes = out.toByteArray();
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
    }

    private void hideSystemBars() {
        WindowInsetsControllerCompat windowInsetsController =
                ViewCompat.getWindowInsetsController(getWindow().getDecorView());
        if (windowInsetsController == null) {
            return;
        }
        // Configure the behavior of the hidden system bars
        windowInsetsController.setSystemBarsBehavior(
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        );
        // Hide both the status bar and the navigation bar
        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars());
    }




}