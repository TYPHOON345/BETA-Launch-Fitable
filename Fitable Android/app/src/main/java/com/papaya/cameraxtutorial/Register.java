package com.papaya.cameraxtutorial;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class Register extends AppCompatActivity {
    EditText newUsername, newEmail, newPassword, checkPassword;
    Button registerBtn;
    Button cancelBtn;
    TextView errorText;
    String email, pwd, username;
    String checkPwd;
    private FirebaseAuth mAuth;
    FirebaseUser currentUser;
    FirebaseApp app = FirebaseApp.initializeApp(this);
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        //Initialise buttons and textbox
        newUsername = findViewById(R.id.newUsername);
        newEmail = findViewById(R.id.newEmail);
        newPassword = findViewById(R.id.newPassword);
        checkPassword = findViewById(R.id.checkPassword);
        registerBtn = findViewById(R.id.registerBtn);
        cancelBtn = findViewById(R.id.cancelBtn);
        errorText = findViewById(R.id.errorText);
        mAuth = FirebaseAuth.getInstance();
        getSupportActionBar().hide();

        registerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                email = String.valueOf(newEmail.getText());
                pwd = String.valueOf(newPassword.getText());
                username = String.valueOf(newUsername.getText());
                checkPwd = String.valueOf(checkPassword.getText());
                if (pwd.equals(checkPwd)) {
                    mAuth.createUserWithEmailAndPassword(email, pwd).addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if (task.isSuccessful()) {
                                Calendar calendar = Calendar.getInstance();
                                SimpleDateFormat df = new SimpleDateFormat("dd MMM yyyy", Locale.US);
                                String date = df.format(calendar.getTime());
                                FirebaseFirestore db = FirebaseFirestore.getInstance();
                                Map<String, Object> user = new HashMap<>();
                                user.put("username", username);
                                user.put("email", email);
                                user.put("level", 1);
                                user.put("joinDate", date);
                                user.put("workouts", Arrays.asList(
                                        new Workout("Fitable", "Squats", "Default Squats Workout", new ArrayList<>(Arrays.asList("squats")), new ArrayList<>(Arrays.asList(20)), 1, 0)
                                ));
                                db.collection("Users").document(email).set(user);
                                transitionToMain();
                            }
                        }
                    });
                }
            }
        });

        cancelBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setResult(Activity.RESULT_CANCELED);
                finish();
            }
        });



    }
    void transitionToMain() {
        Intent intent = new Intent(this, MainMenu.class);
        setResult(Activity.RESULT_OK);
        startActivity(intent);
        finish();
    }
}
