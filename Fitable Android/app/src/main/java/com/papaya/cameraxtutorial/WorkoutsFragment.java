package com.papaya.cameraxtutorial;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Parcelable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link WorkoutsFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class WorkoutsFragment extends Fragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    public WorkoutsFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment WorkoutsFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static WorkoutsFragment newInstance(String param1, String param2) {
        WorkoutsFragment fragment = new WorkoutsFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_workouts, container, false);
        ArrayList<Workout> workoutList = new ArrayList<>();
        RecyclerView mRecyclerView = rootView.findViewById(R.id.workoutsRecyclerView);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false));
        WorkoutsAdapter mAdapter = new WorkoutsAdapter(getActivity(), workoutList, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), StartExerciseActivity.class);
                Workout currentWorkout = workoutList.get(mRecyclerView.getChildLayoutPosition(view));
                intent.putExtra("workout", currentWorkout);
                startActivity(intent);
            }
        });
        mRecyclerView.setAdapter(mAdapter);

        FirebaseFirestore db = FirebaseFirestore.getInstance();
        FirebaseAuth mAuth = FirebaseAuth.getInstance();
        FirebaseUser currentUser = mAuth.getCurrentUser();
        final DocumentReference docRef = db.collection("Users").document(currentUser.getEmail());
        docRef.addSnapshotListener(new EventListener<DocumentSnapshot>() {
            @Override
            public void onEvent(@Nullable DocumentSnapshot value, @Nullable FirebaseFirestoreException e) {
                if (e != null) {
                    e.printStackTrace();
                } else if (value != null && value.exists()) {
                    workoutList.clear();
                    ArrayList<HashMap<String, Object>> rawWorkouts = (ArrayList<HashMap<String, Object>>) value.get("workouts");
                    for (HashMap<String, Object> workout : rawWorkouts) {
                        ArrayList<Integer> intList = new ArrayList<>();
                        for (Long l : (ArrayList<Long>) workout.get("reps")) intList.add(l.intValue());
                        Workout newWorkout = new Workout((String) workout.get("creator"), (String) workout.get("name"), (String) workout.get("description"),
                                (ArrayList<String>) workout.get("exercises"), intList, ((Long) workout.get("sets")).intValue(),
                                ((Long) workout.get("time")).intValue());
                                workoutList.add(newWorkout);
                    }
                    mAdapter.notifyDataSetChanged();
                }
            }
        });

        return rootView;
    }
}