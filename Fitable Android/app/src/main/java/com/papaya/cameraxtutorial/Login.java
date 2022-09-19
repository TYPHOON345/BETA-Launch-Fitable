package com.papaya.cameraxtutorial;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
import android.os.Debug;
import android.util.JsonReader;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
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
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthProvider;
import com.papaya.cameraxtutorial.R;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import io.realm.mongodb.User;


public class Login extends AppCompatActivity {
    EditText emailTxtField;
    EditText pwdTxtField;
    TextView loginText;
    TextView registerBtn;
    String email, pwd;
    FirebaseUser currentUser;
    private static final int SIGN_IN = 2;
    private FirebaseAuth mAuth;
    private GoogleSignInClient signInClient;
    private GoogleSignInOptions gso;
    ActivityResultLauncher<Intent> mStartRegisterForResult = registerForActivityResult(new ActivityResultContracts.StartActivityForResult()
            , new ActivityResultCallback<ActivityResult>() {
        @Override
        public void onActivityResult(ActivityResult result) {
            if (result.getResultCode() == Activity.RESULT_OK) {
                finish();
            }
        }
    });
    @Override
    protected void onCreate(Bundle savedBundleInstance) {

        super.onCreate(savedBundleInstance);
        setContentView(R.layout.activity_login);
        mAuth = FirebaseAuth.getInstance();
        Button loginBtn = findViewById(R.id.loginBtn);
        Button googleLoginBtn = findViewById(R.id.googleSignIn);
        registerBtn = findViewById(R.id.registerBtn);
        emailTxtField = findViewById(R.id.emailTxtField);
        pwdTxtField = findViewById(R.id.passTxtField);
        loginText = findViewById(R.id.loginText);
        currentUser = mAuth.getCurrentUser();
        if (currentUser != null) {
            transitionToMain();
        }
        getSupportActionBar().hide();

        gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail().requestId().requestIdToken(getString(R.string.default_web_client_id)).build();
        signInClient = GoogleSignIn.getClient(this, gso);


        registerBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                transitionToRegister();
            }
        });

        loginBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                email = String.valueOf(emailTxtField.getText());
                pwd = String.valueOf(pwdTxtField.getText());
                loginText.setText("Loading...");
                if (email != null && pwd != null) {
                    mAuth.signInWithEmailAndPassword(email, pwd)
                            .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if (task.isSuccessful()) {
                                Log.d("LOGIN", "signInComplete");
                                currentUser = mAuth.getCurrentUser();
                                transitionToMain();
                            } else {
                                Log.w("LOGIN", "signInFailed");
                                loginText.setText("Email or password incorrect. Please try again.");
                            }
                        }
                    });
                } else {
                    loginText.setText("Please enter your email and password");
                }
            }
        });

        googleLoginBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = signInClient.getSignInIntent();
                startActivityForResult(intent, SIGN_IN);
            }
        });



    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case SIGN_IN:
                try {
                    Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
                    String idToken = task.getResult(ApiException.class).getIdToken();
                    if (idToken !=  null) {
                        AuthCredential firebaseCredential = GoogleAuthProvider.getCredential(idToken, null);
                        mAuth.signInWithCredential(firebaseCredential)
                                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                                    @Override
                                    public void onComplete(@NonNull Task<AuthResult> task) {
                                        if (task.isSuccessful()) {
                                            // Sign in success, update UI with the signed-in user's information
                                            Log.d("SIGN IN", "signInWithCredential:success");
                                            boolean isNew = task.getResult().getAdditionalUserInfo().isNewUser();
                                            if (isNew) {

                                                Intent intent = new Intent(Login.this, UsernameActivity.class);
                                                finish();
                                                startActivity(intent);
                                            } else {
                                                transitionToMain();
                                            }

                                        } else {
                                            // If sign in fails, display a message to the user.
                                            Log.w("SIGN IN", "signInWithCredential:failure", task.getException());

                                        }
                                    }
                                });
                        Log.d("SIGN IN", "Got ID token.");
                    }
                } catch (ApiException e) {
                    e.printStackTrace();
                }
                break;
        }
    }

    void transitionToMain() {
        Intent intent = new Intent(this, MainMenu.class);
        finish();
        startActivity(intent);
    }

    void transitionToRegister() {
        Intent intent = new Intent(this, Register.class);
        mStartRegisterForResult.launch(intent);
    }



}
