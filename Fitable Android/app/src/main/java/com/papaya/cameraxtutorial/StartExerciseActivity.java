package com.papaya.cameraxtutorial;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class StartExerciseActivity extends AppCompatActivity {

    TextView workoutTitle, workoutDescription, workoutExercises, workoutRep;
    Button startBtn, cancelBtn;
    Workout workout;
    String exercisesDescription = "";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_start_exercise);
        getSupportActionBar().hide();
        Intent intent = getIntent();
        workout = (Workout) intent.getSerializableExtra("workout");
        workoutTitle = findViewById(R.id.workoutTitle);
        workoutDescription = findViewById(R.id.workoutsDescription);
        workoutExercises = findViewById(R.id.workoutExercises);
        workoutRep = findViewById(R.id.workoutsReps);
        startBtn = findViewById(R.id.workoutStartBtn);
        cancelBtn = findViewById(R.id.workoutCancelBtn);
        cancelBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
        startBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(StartExerciseActivity.this, MainActivity.class);
                intent.putExtra("exercise", "squats");
                startActivity(intent);
            }
        });
        workoutTitle.setText(workout.getName());
        workoutDescription.setText(workout.getDescription());
        for (String exercise : workout.getExercises()) {
            exercisesDescription += String.format("%s x%d \n", exercise, workout.getReps().get(workout.getExercises().indexOf(exercise)));
        }
        workoutExercises.setText(exercisesDescription);
        workoutRep.setText("Sets: " + String.valueOf(workout.getSets()));

    }
}