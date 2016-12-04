package com.example.ylin.myapplication;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

public class ShowResult extends AppCompatActivity {




    DBHelper  db;
    private EditText name;
    private int maxco,perfects,greats,misses,scores,modes;
    private  int hards = 9349784 , easys = 5104748;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout);



        Bundle bundle = this.getIntent().getExtras();

        maxco = bundle.getInt("maxcombo");
        perfects = bundle.getInt("perfect");
        greats = bundle.getInt("great");
        misses = bundle.getInt("miss");
        scores = bundle.getInt("score");
        modes = bundle.getInt("mode");

        TextView maxcombo = (TextView)findViewById(R.id.maxcom);
        TextView perfect = (TextView)findViewById(R.id.perf);
        TextView great = (TextView)findViewById(R.id.great);
        TextView miss= (TextView)findViewById(R.id.miss);
        TextView score =(TextView)findViewById(R.id.score);

        maxcombo.setText("Maxcombo: "+maxco);
        perfect.setText("Perfect: "+perfects );
        great.setText("Great: "+greats);
        miss.setText("Miss: "+misses);
        score.setText("Score: "+scores);





         name = (EditText)findViewById(R.id.editname);

        if (modes == 3)
        {
            name.setText("AutoPlay");
            name.setEnabled(false);
            name.setFocusable(false);
        }


        ImageView level = (ImageView)findViewById(R.id.levelview);

        if (modes == 1 || modes == 3)
        {
            //hard
            if (scores >= 0.9 * hards)
            {
                //s
                level.setImageResource(R.drawable.levels);
            }
            else if (scores >=0.85* hards)
            {
                //a
            }
            else if (scores >= 0.6 * hards)
            {
                //b
                level.setImageResource(R.drawable.blevel);
            }
            else
            {
                //c
                level.setImageResource(R.drawable.levelc);
            }




        }
        else if (modes == 0)
        {
            //easy
            if (scores >= 0.9 * easys)
            {
                //s
                level.setImageResource(R.drawable.levels);
            }
            else if (scores >=0.85* easys)
            {
                //a
            }
            else if (scores >= 0.6 * easys)
            {
                //b
                level.setImageResource(R.drawable.blevel);
            }
            else
            {
                //c
                level.setImageResource(R.drawable.levelc);
            }



        }





        db = new  DBHelper(this);
        db.CreateTable();

        Button game = (Button)findViewById(R.id.gamebtn);
        Button back =(Button)findViewById(R.id.back);
        game.getBackground().setAlpha(100);
        back.getBackground().setAlpha(100);





        game.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                String na = name.getText().toString().trim();
                if (TextUtils.isEmpty(name.getText()))
                {
                    Toast.makeText(getApplicationContext(), "Please Input name!", Toast.LENGTH_SHORT).show();// 显示时间较短

                }
                else
                {

                    if (modes == 3)
                    {
                        Intent intent = new Intent(ShowResult.this,Autoplay.class);
                        startActivity(intent);
                    }
                    else
                    {
                        db.save(na,scores,maxco);
                        Intent in = new Intent(ShowResult.this,GameActivity.class);
                        Bundle bundle = new Bundle();
                        bundle.putInt("mode", modes);
                        in.putExtras(bundle);
                        startActivity(in);
                    }




                }


            }
        });

        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String na = name.getText().toString().trim();
                if (TextUtils.isEmpty(name.getText()))
                {
                    Toast.makeText(getApplicationContext(), "Please Input name!", Toast.LENGTH_SHORT).show();// 显示时间较短

                }
                else
                {
                    db.save(na,scores,maxco);
                    Intent in = new Intent(ShowResult.this,MainActivity.class);
                    startActivity(in);
                }



            }
        });




    }

    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode== android.view.KeyEvent.KEYCODE_BACK){
            //do nothing

        }
        return true;
    }
}
