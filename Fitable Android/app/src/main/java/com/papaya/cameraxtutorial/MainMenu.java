package com.papaya.cameraxtutorial;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.navigation.NavController;
import androidx.navigation.fragment.NavHostFragment;
import androidx.navigation.ui.NavigationUI;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.google.android.material.bottomnavigation.BottomNavigationView;

import org.checkerframework.checker.units.qual.A;

import java.util.ArrayList;

public class MainMenu extends AppCompatActivity {
    NavHostFragment navHostFragment;
    NavController navController;
    BottomNavigationView bottomNav;
    FragmentManager supportFragmentManager;
    ArrayList<Thread> threads = new ArrayList<>();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_menu);
        getSupportActionBar().hide();
        supportFragmentManager = getSupportFragmentManager();
        navHostFragment = (NavHostFragment) supportFragmentManager.findFragmentById(R.id.nav_fragment);
        navController = navHostFragment.getNavController();
        bottomNav = findViewById(R.id.bottom_navigation_view);
        NavigationUI.setupWithNavController(bottomNav, navController);

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
            Fragment activeFragment = navHostFragment.getChildFragmentManager().getPrimaryNavigationFragment();
            activeFragment.onActivityResult(requestCode, resultCode, data);
    }

    public void restartCurrentFragment() {
        FragmentManager navigationFragmentManager = navHostFragment.getChildFragmentManager();
        Fragment currentFragment = navigationFragmentManager.getPrimaryNavigationFragment();
        navigationFragmentManager.beginTransaction().detach(currentFragment).commit();
        navigationFragmentManager.beginTransaction().attach(currentFragment).commit();

    }

    public void stopAllThreads() {
        for (Thread thread : threads) {
            thread.interrupt();
        }
    }

    public void addThread(Thread thread) {
        threads.add(thread);
    }
}