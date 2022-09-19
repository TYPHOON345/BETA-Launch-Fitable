package com.papaya.cameraxtutorial;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

public class WorkoutsAdapter extends RecyclerView.Adapter<WorkoutsAdapter.ViewHolder> {
    Context context;
    ArrayList<Workout> workoutList;
    View.OnClickListener onClickListener;

    public WorkoutsAdapter(Context context, ArrayList<Workout> workoutList, View.OnClickListener onClickListener) {
        this.context = context;
        this.workoutList = workoutList;
        this.onClickListener = onClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(context).inflate(R.layout.workout_card, parent, false);
        v.setOnClickListener(onClickListener);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Workout workout = workoutList.get(position);
        holder.workoutName.setText(workout.getName());
        holder.workoutDescription.setText(workout.getDescription());
    }

    @Override
    public int getItemCount() {
        return workoutList.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        TextView workoutName, workoutDescription;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            workoutName = itemView.findViewById(R.id.workoutName);
            workoutDescription = itemView.findViewById(R.id.workoutDescription);
        }


    }

}
