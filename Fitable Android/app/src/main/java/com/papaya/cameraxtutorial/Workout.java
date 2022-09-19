package com.papaya.cameraxtutorial;

import java.util.ArrayList;
import java.util.Objects;
import java.io.Serializable;

public class Workout implements Serializable{
    String creator;
    String name;
    String description;
    ArrayList<String> exercises;
    ArrayList<Integer> reps;
    int sets;
    int time;

    public Workout() {
        //empty constructor required
    }

    public Workout(String creator, String name, String description, ArrayList<String> exercises, ArrayList<Integer> reps, int sets, int time) {
        this.creator = creator;
        this.name = name;
        this.description = Objects.equals(description, "") ? "No Description" : description;
        this.exercises = exercises;
        this.reps = reps;
        this.sets = sets;
        this.time = time;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public ArrayList<String> getExercises() {
        return exercises;
    }

    public void setExercises(ArrayList<String> exercises) {
        this.exercises = exercises;
    }

    public ArrayList<Integer> getReps() {
        return reps;
    }

    public void setReps(ArrayList<Integer> reps) {
        this.reps = reps;
    }

    public int getSets() {
        return sets;
    }

    public void setSets(int sets) {
        this.sets = sets;
    }

    public int getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }

}
