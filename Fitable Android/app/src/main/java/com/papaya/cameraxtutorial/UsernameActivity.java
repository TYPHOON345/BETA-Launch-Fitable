package com.papaya.cameraxtutorial;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class UsernameActivity extends AppCompatActivity {
    EditText newUsername;
    Button continueBtn;
    FirebaseUser currentUser;
    FirebaseFirestore db;
    FirebaseAuth mAuth;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_username);
        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();
        currentUser = mAuth.getCurrentUser();
        newUsername = findViewById(R.id.newUsernameGoogle);
        continueBtn = findViewById(R.id.continueBtn);
        getSupportActionBar().hide();
        continueBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Calendar calendar = Calendar.getInstance();
                SimpleDateFormat df = new SimpleDateFormat("dd MMM yyyy", Locale.US);
                String date = df.format(calendar.getTime());
                String email = currentUser.getEmail();
                String username = String.valueOf(newUsername.getText());
                Map<String, Object> user = new HashMap<>();
                user.put("username", username);
                user.put("email", email);
                user.put("level", 1);
                user.put("joinDate", date);
                user.put("workouts", Arrays.asList(
                        new Workout("Fitable", "Squats", "Default Squats Workout",
                                new ArrayList<>(Arrays.asList("squats")), new ArrayList<>(Arrays.asList(20)), 1, 0)
                        ));
                db.collection("Users").document(email).set(user);
                transitionToMain();
            }
        });
    }

    void transitionToMain() {
        Intent intent = new Intent(this, MainMenu.class);
        startActivity(intent);
        finish();
    }
}
