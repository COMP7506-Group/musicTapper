package com.example.ylin.myapplication;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class GameActivity extends AppCompatActivity {


    private int state = 2;
    private int pauseindex ;
    private int time = 0;
    private int stoptime , restarttime ;
    private int combo = 0;
    private int count = 0 ;
    private int counter = 5 ;
    private ImageButton fbtn,sbtn,thrbtn,fourbtn = null;

    ImageButton butto[] = new ImageButton[633];
    RelativeLayout relativeLayout ;
    private ObjectAnimator[] a = new ObjectAnimator[633];
    private MediaPlayer mediaPlayer1 ;
    private TextView tv,comb;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.animation_basic);


        tv = (TextView)findViewById(R.id.textView);
        comb =(TextView)findViewById(R.id.textView3);

        relativeLayout = (RelativeLayout)findViewById(R.id.rv);
         mediaPlayer1 = MediaPlayer.create(this,R.raw.first);
      //  final MediaPlayer mediaPlayer2 = MediaPlayer.create(this,R.raw.good);


        initButton();
        startGame();
        mediaPlayer1.start();

        //  btn = new ImageButton(this);
        //btn.setText("auto");

        //  btn.setId(id);

        //   relativeLayout.addView(btn);

        handler.postDelayed(runnable,1);



        sbtn = (ImageButton)findViewById(R.id.p2);
        fbtn = (ImageButton)findViewById(R.id.p1);
        thrbtn=(ImageButton)findViewById(R.id.p3);
        fourbtn=(ImageButton)findViewById(R.id.p4);

        Button pauseButton;
        pauseButton = (Button)findViewById(R.id.pause);
        pauseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {



                count++;
                if (count % 2 == 0 && count !=0 )
                {
                    state = 0 ;// play
                    restartAnimaton();
                    mediaPlayer1.start();
                    time =  time - stoptime ;
                }else if(count % 2 == 1 )
                {
                    stoptime = time ;
                    state = 1 ; //pause
                    pauseAnimation();
                    mediaPlayer1.pause();
                    Log.e("The state of the game:",""+state);
                }
                Log.e("The count of pause:",""+count);


            }
        });





        fbtn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                tv.setText("");
                comb.setText("");
                Log.v("!!!!!2222!!","click");
                Isclick(1);




            }
        });
        sbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tv.setText("");
                comb.setText("");
                Isclick(2);

            }
        });
        thrbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tv.setText("");
                comb.setText("");
                Isclick(3);
            }
        });
        fourbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tv.setText("");
                comb.setText("");
                Isclick(4);
            }
        });




    }

    private void Isclick(int ind) {


         int[] tim=this.getResources().getIntArray(R.array.notetime);
         int[] track=this.getResources().getIntArray(R.array.track);
        for (int i=0 ; i<track.length;i++)
        {
            if (track[i] == ind){


                if (time>tim[i]-50 && time<tim[i]+50)
                {
                    //playmusic();
                    // mediaPlayer1.start();
                    combo++;
                    tv.setText("Perfect!");
                    comb.setText("combo:"+combo);
                    Log.v("!!!!!66666666!!","perfect");
                    Log.v("!!!!!time!!", String.valueOf(time));
                    Log.v("!!!!!combo!!", String.valueOf(combo));

                }
               else if (time>tim[i]-160 && time<tim[i]+160)
                {
                    //playmusic();
                    // mediaPlayer1.start();
                    combo++;
                    tv.setText("Great!");
                    comb.setText("combo:"+combo);
                    Log.v("!!!!!combo!!", String.valueOf(combo));
                   // Log.v("!!!!!66666666!!","good");
                  //  Log.v("!!!!!time!!", String.valueOf(time));
                   // Log.v("!!!!!tim[]!!", String.valueOf(tim[i]));

                }
                else if(time > tim[i]+250) {
                      tv.setText("MISS");
                    combo =0;
                }

            }
            else
            {
                        //no nothing
            }
        }


    }

    private void initButton() {

        // @android.support.annotation.IdRes int id = count ;
        @android.support.annotation.IdRes int id2 = counter ;

        for (int i = 0; i<633 ;i++ )
        {
            butto[i] = new ImageButton(this);
            butto[i].setId(id2);
            butto[i].setImageResource(R.drawable.note5);
            butto[i].setBackgroundColor(Color.TRANSPARENT);
            butto[i].setVisibility(View.GONE);
            relativeLayout.addView(butto[i]);
        }
    }


    Handler handler = new Handler();
    Runnable runnable = new Runnable() {
        @Override
        public void run() {

            time = mediaPlayer1.getCurrentPosition();
            // time ++ ;//100ms
            handler.postDelayed(this,1);

           // Log.v("!!!!!!!!TIME!!!!!!!", String.valueOf(time));
        }
    };






    private void doTranslationXAnimation(final int index) {
        int[] tim=this.getResources().getIntArray(R.array.notetime);
        int[] track=this.getResources().getIntArray(R.array.track);

      //  int tim[] = new int[]{1750,1979,2208,2895,3124,3811,4040,4269,4498,4727,4956,5414,5643,5872,6559,6788,7475,7704,7933 };

        Log.e("!!!!!!!!show index","======"+index);

        if (track[index]-1 == 0)
        {
            butto[index].setX(10);

        }
        else if (track[index]-1 == 1)
        {
            butto[index].setX(126);
        }
        else  if (track[index]-1 == 2)
        {
            butto[index].setX(242);
        }
        else  if (track[index]-1 == 3)
        {
            butto[index].setX(358);
        }

       // butto[0].setVisibility(View.VISIBLE);
        a[index] = ObjectAnimator.ofFloat(butto[index], "translationY", 0, 590);
        a[index].setStartDelay(tim[index]-2000);
        // a[0] = animator.clone();
        //  a[0].setTarget(mStartButton);
        // a[0].setStartDelay(150);
        // a[0].setDuration(3000);
        a[index].setInterpolator(new LinearInterpolator());
        a[index].setDuration(2016);
        a[index].start();

        a[index].addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                butto[index].setVisibility(View.VISIBLE);
                tv.setText("");
                comb.setText("");
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                butto[index].setVisibility(View.GONE);

            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        // a[0].start();

    }


    public void pauseAnimation(){
        for (int i = pauseindex ; i < 633 ;i ++)
        {
            a[i].pause();
        }
    }

    public void restartAnimaton(){
        for (int i = pauseindex ; i < 633 ;i ++)
        {
            a[i].resume();
        }

    }
    public void startGame()
    {

        for (int in =0 ;in <633 ; in++)
        {
            doTranslationXAnimation(in);
            if (state == 1)
            {
                pauseindex = in ;
            }
        }
    }
}
