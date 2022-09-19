package com.papaya.cameraxtutorial;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.api.services.classroom.model.Course;

import java.util.ArrayList;
import java.util.List;

public class ClassAdapter extends RecyclerView.Adapter<ClassAdapter.ViewHolder> {

    ArrayList<Course> courses = new ArrayList<>();
    Context context;

    public ClassAdapter(Context context, ArrayList<Course> courses) {
        this.context = context;
        this.courses = courses;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(context).inflate(R.layout.classroom_class, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        if (courses != null && !courses.isEmpty()) {
            Course currentCourse = courses.get(position);
            holder.className.setText(currentCourse.getName());
            holder.assignExercise(currentCourse);
        }
    }

    @Override
    public int getItemCount() {
        if (courses != null) {
            return courses.size();
        } else {
            return 0;
        }
    }

    public class ViewHolder extends RecyclerView.ViewHolder {

        Button assignButton;
        TextView className;
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            assignButton = itemView.findViewById(R.id.assignBtn);
            className = itemView.findViewById(R.id.className);
        }

        void assignExercise(Course course) {
            assignButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    //TODO: assign assignment to class
                }
            });
        }
    }
}
