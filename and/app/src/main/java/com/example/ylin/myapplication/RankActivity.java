package com.example.ylin.myapplication;

import android.content.Intent;
import android.database.Cursor;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.SimpleCursorAdapter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class RankActivity extends AppCompatActivity {



    DBHelper  db;
    private EditText ed;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rank);

        db = new  DBHelper(this);
        db.CreateTable();



        ed = (EditText)findViewById(R.id.name);
        Button okbtn = (Button)findViewById(R.id.okbtn) ;
        okbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = ed.getText().toString().trim();
                int score =0 ; int max = 1;
                db.save(name,score,max);


            }
        });




        Button viewbtn = (Button)findViewById(R.id.viewrankbtn);
        viewbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Intent intent = new Intent(RankActivity.this,ViewRank.class);
                startActivity(intent);


            }
        });


    }




}
