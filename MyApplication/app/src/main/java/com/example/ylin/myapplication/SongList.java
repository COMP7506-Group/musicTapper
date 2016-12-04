package com.example.ylin.myapplication;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

public class SongList extends AppCompatActivity {

    private  TextView choose ;
    private  int f =0;
    private int mode = 1;//hard
    private  int modef =0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_song_list);

         choose = (TextView)findViewById(R.id.choice);
        ImageView im1 = (ImageView)findViewById(R.id.m1);
        ImageView im2 = (ImageView)findViewById(R.id.im);
        ImageView im3 = (ImageView)findViewById(R.id.m3);
        ImageView im4 = (ImageView)findViewById(R.id.m4);

        Button stbtn = (Button)findViewById(R.id.gamest) ;
        stbtn.getBackground().setAlpha(100);

        RadioGroup m = (RadioGroup)findViewById(R.id.gamemode);
        final RadioButton easy =(RadioButton)findViewById(R.id.easym);
        final RadioButton hard =(RadioButton)findViewById(R.id.hardm);

        m.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                if (easy.getId() == checkedId)
                {
                    mode = 0;//easy
                    modef=1;
                }
                else if(hard.getId() == checkedId)
                {
                    mode =1 ;//hard
                    modef=1 ;
                }
            }
        });















        im1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                f=1;
                showsong();
            }


        });
        im2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                f=1;
                showsong();
            }


        });
        im3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                f=1;
                showsong();
            }


        });

        im4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                f=1;
                showsong();
            }


        });



        stbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (f == 0 || modef == 0)
                {
                    Toast.makeText(getApplicationContext(), "Please complete the choice", Toast.LENGTH_LONG).show();

                }
                else if (f ==1 && modef == 1)
                {
                    Intent in = new Intent(SongList.this,GameActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putInt("mode", mode);
                    in.putExtras(bundle);
                    startActivity(in);
                }

            }
        });


    }

    private void showsong() {

        choose.setText("Music: 極楽浄土" );

    }
}
