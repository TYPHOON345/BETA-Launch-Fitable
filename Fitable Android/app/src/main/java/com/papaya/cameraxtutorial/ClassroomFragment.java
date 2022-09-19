package com.papaya.cameraxtutorial;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Environment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.gms.auth.api.identity.BeginSignInRequest;
import com.google.android.gms.auth.api.identity.BeginSignInResult;
import com.google.android.gms.auth.api.identity.Identity;
import com.google.android.gms.auth.api.identity.SignInClient;
import com.google.android.gms.auth.api.identity.SignInCredential;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.internal.GoogleSignInOptionsExtensionParcelable;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.api.client.auth.oauth2.AuthorizationCodeFlow;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeRequestUrl;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.googleapis.extensions.android.gms.auth.GoogleAccountCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpRequest;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.HttpResponse;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.classroom.Classroom;
import com.google.api.services.classroom.ClassroomScopes;
import com.google.api.services.classroom.model.Course;
import com.google.api.services.classroom.model.ListCoursesResponse;
import com.google.api.services.classroom.Classroom.Courses;
import com.google.api.services.classroom.model.ListTeachersResponse;
import com.google.api.services.classroom.model.Teacher;
import com.google.auth.Credentials;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.AccessToken;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthCredential;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.UserInfo;


import org.w3c.dom.Text;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ExecutionException;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link ClassroomFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ClassroomFragment extends Fragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";
    private final int SIGN_IN = 1;
    private final int REQUEST_CLASSROOM_PERMISSION = 2;
    private GoogleSignInClient signInClient;
    private GoogleSignInOptions gso;
    private FirebaseAuth mAuth;
    private FirebaseUser currentUser;
    private ArrayList<Course> teacherCourses = new ArrayList<>();
    private RecyclerView recyclerView;
    private ClassAdapter classAdapter;
    private Classroom service;

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    public ClassroomFragment() {
        // Required empty public constructor
    }


    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment ClassroomFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static ClassroomFragment newInstance(String param1, String param2) {
        ClassroomFragment fragment = new ClassroomFragment();
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
        View rootView = inflater.inflate(R.layout.fragment_classroom, container, false);
        mAuth = FirebaseAuth.getInstance();
        currentUser = mAuth.getCurrentUser();

        recyclerView = rootView.findViewById(R.id.classroomRecyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false));
        classAdapter = new ClassAdapter(getActivity(), teacherCourses);
        recyclerView.setAdapter(classAdapter);

        gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail().requestId().requestIdToken(getString(R.string.default_web_client_id)).build();
        signInClient = GoogleSignIn.getClient(getActivity(), gso);

        RelativeLayout notGoogle = rootView.findViewById(R.id.noGoogle);
        TextView noGoogleSignIn = rootView.findViewById(R.id.noGoogleSignIn);
        if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(getActivity(), new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 100);
        }
        boolean loggedInWithGoogle = false;
        for (UserInfo profile : currentUser.getProviderData()) {
            if (profile.getProviderId().equals("google.com")) {
                loggedInWithGoogle = true;
                break;
            }
        }
        if (!loggedInWithGoogle) {
            notGoogle.setVisibility(View.VISIBLE);
            noGoogleSignIn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent intent = signInClient.getSignInIntent();
                    startActivityForResult(intent, SIGN_IN);
                }
            });
        } else {
            recyclerView.setVisibility(View.VISIBLE);
        }


        if (!GoogleSignIn.hasPermissions(
                GoogleSignIn.getLastSignedInAccount(getActivity()),
                new Scope(ClassroomScopes.CLASSROOM_COURSES_READONLY),
                new Scope(ClassroomScopes.CLASSROOM_ROSTERS_READONLY))) {
            GoogleSignIn.requestPermissions(getActivity(),
                    REQUEST_CLASSROOM_PERMISSION,
                    GoogleSignIn.getLastSignedInAccount(getActivity()),
                    new Scope(ClassroomScopes.CLASSROOM_COURSES_READONLY),
                    new Scope(ClassroomScopes.CLASSROOM_ROSTERS_READONLY));
        } else {
            try {
                getCourses();
            } catch (IOException | GeneralSecurityException | InterruptedException | ExecutionException e) {
                e.printStackTrace();
            }
        }





        return rootView;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Activity.RESULT_OK) {
            switch (requestCode) {
                case SIGN_IN:
                    try {
                        Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
                        String idToken = task.getResult(ApiException.class).getIdToken();
                        if (idToken != null) {
                            AuthCredential firebaseCredential = GoogleAuthProvider.getCredential(idToken, null);
                            mAuth.getCurrentUser().linkWithCredential(firebaseCredential).addOnCompleteListener(getActivity(), new OnCompleteListener<AuthResult>() {
                                @Override
                                public void onComplete(@NonNull Task<AuthResult> task) {
                                    if (task.isSuccessful()) {
                                        ((MainMenu) getActivity()).restartCurrentFragment();
                                    }
                                }
                            });
                        }
                    } catch (ApiException e) {
                        e.printStackTrace();
                    }
                    break;
                case REQUEST_CLASSROOM_PERMISSION:
                    ((MainMenu) getActivity()).restartCurrentFragment();
                    break;
            }
        }
    }

    boolean checkIfTeacher(Course course) throws IOException {
        String pageToken = null;
        do {
            ListTeachersResponse response = service.courses().teachers().list(course.getId())
                    .setPageSize(100)
                    .setPageToken(pageToken)
                    .execute();
            for (Teacher teacher : response.getTeachers()) {
                if (GoogleSignIn.getLastSignedInAccount(getActivity()).getId().equals(teacher.getUserId())) {
                    return true;
                }
            }

            pageToken = response.getNextPageToken();
        } while (pageToken != null);
        return false;
    }

    void getCourses() throws IOException, GeneralSecurityException, ExecutionException, InterruptedException {
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail().build();
        GoogleSignInClient signInClient = GoogleSignIn.getClient(getActivity(), gso);
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                GoogleSignInAccount user = null;
                try {
                    user = Tasks.await(signInClient.silentSignIn());
                    List<Course> courses = new ArrayList<>();
                    GoogleAccountCredential credential = GoogleAccountCredential.usingOAuth2(
                            getActivity(),
                            Arrays.asList(ClassroomScopes.CLASSROOM_ROSTERS_READONLY,
                                    ClassroomScopes.CLASSROOM_COURSES_READONLY));
                    credential.setSelectedAccount(user.getAccount());
                    service = new Classroom.Builder(new NetHttpTransport(),
                            GsonFactory.getDefaultInstance(),
                            credential)
                            .setApplicationName("Fitable")
                            .build();
                    String pageToken = null;
                    do {
                        ListCoursesResponse response = service.courses().list()
                                .setPageSize(100)
                                .setPageToken(pageToken)
                                .execute();
                        courses.addAll(response.getCourses());
                        pageToken = response.getNextPageToken();
                    } while (pageToken != null);
                    Log.d("CLASSROOM", String.valueOf(courses));
                    if (courses.isEmpty()) {
                        System.out.println("No courses found.");
                    } else {
                        for (Course course : courses) {
                            if (checkIfTeacher(course)) {
                                teacherCourses.add(course);
                            }
                        }
                    }
                    Log.d("CLASSROOM", String.valueOf(teacherCourses));
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            classAdapter.notifyDataSetChanged();
                        }
                    });
                } catch (ExecutionException | InterruptedException | IOException e) {
                    e.printStackTrace();
                }

            }

        });
        ((MainMenu) getActivity()).addThread(thread);
        thread.start();


    }




}