package com.example.ylin.myapplication;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;


public class MainActivity extends AppCompatActivity  {



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button startbtn = (Button)findViewById(R.id.startbtn);
        Button rankbtn =(Button)findViewById(R.id.rankbtn);
        Button ranktbtn = (Button)findViewById(R.id.viewrank);

        startbtn.getBackground().setAlpha(50);
        rankbtn.getBackground().setAlpha(50);
        ranktbtn.getBackground().setAlpha(50);


        startbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this,SongList.class);
                startActivity(intent);
            }
        });

        rankbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this,Autoplay.class);
                startActivity(intent);
            }
        });

        ranktbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this,ViewRank.class);
                startActivity(intent);

            }
        });

    }

}
