package com.example.ylin.myapplication;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.graphics.Color;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

public class GameActivity extends AppCompatActivity {


    private int state = 2;
    private int pauseindex ;
    private int time = 0;
    private float x,x1,x2,x3 ,y;
    private int count = 0 ;
    private int counter = 5 ;
    private ImageButton fbtn,sbtn,tbtn3,fourbtn = null;
    private View mStartButton = null;
    private View mTargetView = null;
    private int mStateId = 0;
    private int mStateCount = 2;
    ImageButton btn ;
    ImageButton btn3,btn4,btn5,btn6,btn7;
    ImageButton butto[] = new ImageButton[10];
    RelativeLayout relativeLayout ;
    private ObjectAnimator[] a = new ObjectAnimator[40];





    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.animation_basic);

        relativeLayout = (RelativeLayout)findViewById(R.id.rv);



        initButton();



        //  btn = new ImageButton(this);
        //btn.setText("auto");

        //  btn.setId(id);

        //   relativeLayout.addView(btn);

        handler.postDelayed(runnable,100);




        sbtn = (ImageButton)findViewById(R.id.p2);
        fbtn = (ImageButton)findViewById(R.id.p1);

        mStartButton = findViewById(R.id.startButton);
        mStartButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {

                startGame();



            }
        });
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
                }else if(count % 2 == 1 )
                {
                    state = 1 ; //pause
                    pauseAnimation();
                    Log.e("The state of the game:",""+state);
                }
                Log.e("The count of pause:",""+count);


            }
        });


        mTargetView = findViewById(R.id.target);
        mTargetView.setVisibility(View.GONE);

        fbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });
        sbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


            }
        });





    }

    private void initButton() {

        // @android.support.annotation.IdRes int id = count ;
        @android.support.annotation.IdRes int id2 = counter ;

        for (int i = 0; i<10 ;i++ )
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
            time ++ ;//100ms
            handler.postDelayed(this,100);

            //   Log.v("!!!!!!!!TIME!!!!!!!", String.valueOf(time));
        }
    };






    private void doTranslationXAnimation(final int index) {

        int tim[] = new int[]{0,500,1000,1500,2000,2500,3000,3500,4000,800};
        Log.e("!!!!!!!!show index","======"+index);

        if (index % 4 == 0)
        {
            butto[index].setX(10);

        }
        else if (index %4 == 1)
        {
            butto[index].setX(126);
        }
        else  if (index %4 == 2)
        {
            butto[index].setX(242);
        }
        else  if (index %4 == 3)
        {
            butto[index].setX(358);
        }

        butto[0].setVisibility(View.VISIBLE);
        a[index] = ObjectAnimator.ofFloat(butto[index], "translationY", 0, 605);
        a[index].setStartDelay(tim[index]);
        // a[0] = animator.clone();
        //  a[0].setTarget(mStartButton);
        // a[0].setStartDelay(150);
        // a[0].setDuration(3000);
        a[index].setInterpolator(new LinearInterpolator());
        a[index].setDuration(3000);
        a[index].start();

        a[index].addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                butto[index].setVisibility(View.VISIBLE);
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
        for (int i = pauseindex ; i < 10 ;i ++)
        {
            a[i].pause();
        }
    }

    public void restartAnimaton(){
        for (int i = pauseindex ; i < 10 ;i ++)
        {
            a[i].resume();
        }

    }
    public void startGame()
    {

        for (int in =0 ;in <10 ; in++)
        {
            doTranslationXAnimation(in);
            if (state == 1)
            {
                pauseindex = in ;
            }
        }
    }
}
