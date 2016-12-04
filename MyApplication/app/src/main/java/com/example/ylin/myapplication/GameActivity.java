package com.example.ylin.myapplication;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Handler;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.lang.reflect.Array;
import java.text.SimpleDateFormat;

public class GameActivity extends AppCompatActivity {
    private int notenum =633 ;
    private int sttime[] = new int[notenum] ;
    private int animtime=0 ,playindex=0 ,time = 0 ,combo = 0 ,miss = 0,count = 0,maxcombo =0,base = 12450 ,perfect =0 ,good =0,great=0;
    private double  score =0 ,maxlevel=0 ;
    private int state = 2;
    private int pauseindex,stoptime ;
    private int clicktime[] = new int[]{0,0,0,0} ;
    private int com[] = new int[notenum];
    private int counter = 5 ;
    private int life =10 ;
    private int flag=1 ;// easy =0 hard=1



    private ImageButton fbtn,sbtn,thrbtn,fourbtn = null;

    ImageButton butto[] = new ImageButton[notenum];
    RelativeLayout relativeLayout ;
    private ObjectAnimator[] a = new ObjectAnimator[notenum];
    private MediaPlayer mediaPlayer1 ;
    private TextView tv,comb,timetxt,scoretxt;
    private SpringProgressView progressView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.animation_basic);

        Bundle bundle = this.getIntent().getExtras();

        flag = bundle.getInt("mode");



        if (flag == 0 )
        {
            notenum = 359;
        }
        else if (flag == 1)
        {
            notenum = 633;
        }








        progressView = (SpringProgressView) findViewById(R.id.progressview);
        progressView.setMaxCount(10.0f);
        progressView.setCurrentCount(10);


        tv = (TextView)findViewById(R.id.textView);
        comb =(TextView)findViewById(R.id.textView3);
        timetxt =(TextView)findViewById(R.id.timetxt);
        scoretxt=(TextView)findViewById(R.id.scoretxt);

        relativeLayout = (RelativeLayout)findViewById(R.id.rv);
       //  mediaPlayer1 = MediaPlayer.create(this,R.raw.first);
      //  final MediaPlayer mediaPlayer2 = MediaPlayer.create(this,R.raw.good);
       // mediaPlayer2 = MediaPlayer.create(this,R.raw.good);


        initButton();
        startGame();




        //  btn.setId(id);

        //   relativeLayout.addView(btn);

        handler.postDelayed(runnable,1);



        sbtn = (ImageButton)findViewById(R.id.p2);
        fbtn = (ImageButton)findViewById(R.id.p1);
        thrbtn=(ImageButton)findViewById(R.id.p3);
        fourbtn=(ImageButton)findViewById(R.id.p4);

        fbtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                if(event.getAction()==MotionEvent.ACTION_DOWN){
                    v.setBackgroundResource(R.drawable.animal);
                   // mediaPlayer2.start();
                    clicktime[0] = time; //click time of the first button
                    Log.e("clicktime",":"+time);
                    //      Log.v("!!!!!2222!!","click");
                    // Isclick(1);
                }
                else if(event.getAction()==MotionEvent.ACTION_UP){
                    v.setBackgroundResource(R.drawable.buttons);
                }

                return false;
            }
        });
        sbtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if(event.getAction()==MotionEvent.ACTION_DOWN){
                    v.setBackgroundResource(R.drawable.animal);
                    //mediaPlayer2.start();
                    clicktime[1] = time;
                    Log.e("clicktime",":"+time);
                    //     Log.v("!!!!!2222!!","click");
                      //Isclick(2);
                }
                else if(event.getAction()==MotionEvent.ACTION_UP){
                    v.setBackgroundResource(R.drawable.buttons);
                }
                return false;

            }
        });
        thrbtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                if(event.getAction()==MotionEvent.ACTION_DOWN){
                    v.setBackgroundResource(R.drawable.animal);
                  //  mediaPlayer2.start();
                    clicktime[2] = time;
                    Log.e("clicktime",":"+time);
                    //       Log.v("!!!!!2222!!","click");
                     // Isclick(3);
                }
                else if(event.getAction()==MotionEvent.ACTION_UP){
                    v.setBackgroundResource(R.drawable.buttons);
                }

                return false;
            }
        });

        fourbtn.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    v.setBackgroundResource(R.drawable.animal);
                    //mediaPlayer2.start();
                    clicktime[3] = time;
                    Log.e("clicktime",":"+time);
                    //          Log.v("!!!!!2222!!", "click");
                   //   Isclick(4);
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    v.setBackgroundResource(R.drawable.buttons);

                }
                return false;
            }
        });




        final Button pauseButton;
        pauseButton = (Button)findViewById(R.id.pause);

        pauseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


              /* float xxx = fbtn.getX();
                float xx2 = sbtn.getX();
                float yy = fbtn.getY();
                Log.v("!!horizontal coordinate", String.valueOf(xxx));
                Log.v("!!horizontal coordinate", String.valueOf(xx2));
                Log.v("!!vertical coordinate", String.valueOf(yy));
                */

                stoptime = time ;
                state = 1 ; //pause
                pauseAnimation();
                mediaPlayer1.pause();
                Log.e("The state of the game:",""+state);
                pauseButton.setBackgroundResource(R.drawable.pause);
                AlertDialog.Builder builder = new AlertDialog.Builder(GameActivity.this);
                builder.setIcon(R.drawable.arank);
                builder.setTitle("Please select the operation");
                //    指定下拉列表的显示数据
                final String[] operation = {"Play", "Restart", "End"};
                //    设置一个下拉的列表选择项
                builder.setItems(operation, new DialogInterface.OnClickListener()
                {
                    @Override
                    public void onClick(DialogInterface dialog, int which)
                    {



                        if (which == 0)
                        {
                            //play
                            state = 0 ;// play
                            restartAnimaton();
                            mediaPlayer1.start();
                            time =  time - stoptime ;
                            pauseButton.setBackgroundResource(R.drawable.play);
                        }
                        else if (which == 1)
                        {
                            //restart
                           //mediaPlayer1.release();

                            Intent in = new Intent(GameActivity.this,GameActivity.class);
                            Bundle bundle = new Bundle();
                            bundle.putInt("mode", flag);
                            in.putExtras(bundle);
                            startActivity(in);

                           // mediaPlayer1.stop();




                        }
                        else if (which == 2)
                        {
                            //endgame
                          //  mediaPlayer1.release();
                            showResult();


                        }


                    }
                });
                builder.show();

/*
                count++;
                if (count % 2 == 0 && count !=0 )
                {
                    state = 0 ;// play
                    restartAnimaton();
                    mediaPlayer1.start();
                    time =  time - stoptime ;
                    pauseButton.setBackgroundResource(R.drawable.play);
                }else if(count % 2 == 1 )
                {
                    stoptime = time ;
                    state = 1 ; //pause
                    pauseAnimation();
                    mediaPlayer1.pause();
                    Log.e("The state of the game:",""+state);
                    pauseButton.setBackgroundResource(R.drawable.pause);
                }
                Log.e("The count of pause:",""+count);
*/

            }
        });




    }



    private void initButton() {






        // @android.support.annotation.IdRes int id = count ;
        @android.support.annotation.IdRes int id2 = counter ;

        for (int i = 0; i<notenum ;i++ )
        {
            com[i] = -1;
            butto[i] = new ImageButton(this);
            butto[i].setId(id2);
            butto[i].setImageResource(R.drawable.newnote);
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




            SimpleDateFormat formatter = new SimpleDateFormat("mm:ss");//初始化Formatter的转换格式。

            String hms = formatter.format(time);
            timetxt.setText(hms);





            // time ++ ;//100ms
            handler.postDelayed(this,1);

           // Log.v("!!!!!!!!TIME!!!!!!!", String.valueOf(time));
        }
    };

    
    private void computeresult() {
                
        if (life>0&&life<10)
        {
            progressView.setCurrentCount(life);
        }
        else if (life>=10)
        {
            progressView.setCurrentCount(10);
            life = 10 ;
        }
        else if (life<=0)
        {
            progressView.setCurrentCount(0);
            mediaPlayer1.pause();
            pauseAnimation();
            showResult();

        }



        score = base * maxlevel*(0.6*good+0.88*great+1*perfect) ;
        int c = (int) score;
        scoretxt.setText("score:"+c);



        }




    private void isMiss() {
        comb.setText("");


        int[] track=this.getResources().getIntArray(R.array.track);


        if (playindex>0 && track[playindex-1] == 1){


            if (clicktime[0]>sttime[playindex-1]-80 && clicktime[0]<sttime[playindex-1]+80)
            {
                //playmusic();
                // mediaPlayer1.start();

                com[playindex-1]=3; //perfect
                perfect++;
                life ++ ;
                combo++;
                comb.setText("combo:"+combo);
                tv.setText("Perfect!");



            }
            else if (clicktime[0]>sttime[playindex-1]-130 && clicktime[0]<sttime[playindex-1]+130)
            {
                //playmusic();
                // mediaPlayer1.start();
                great++;
                com[playindex-1]=2; //great
                combo++;
                life++;
                tv.setText("Great!");
                comb.setText("combo:"+combo);

            }
            else if (clicktime[0]>sttime[playindex-1]-300 && clicktime[0]<sttime[playindex-1]+300) {
                tv.setText("GOOD!");
                good++;
                combo = 0;
                life -- ;

          //      Log.v("!!!!!Miss!!", String.valueOf(combo));
            }
            else
            {
                tv.setText("MISS!");
                miss++;
                combo = 0;
                life--;
              //  combo =0;
            }

        }  else if (playindex>0 && track[playindex-1] == 2)
        {


            if (clicktime[1]>sttime[playindex-1]-80 && clicktime[1]<sttime[playindex-1]+80)
            {
                //playmusic();
                // mediaPlayer1.start();
                com[playindex-1]=1;
                perfect++;
                combo++;
                life++;
                tv.setText("Perfect!");
                comb.setText("combo:"+combo);


            }
            else  if (clicktime[1]>sttime[playindex-1]-130 && clicktime[1]<sttime[playindex-1]+130)
            {
                //playmusic();
                // mediaPlayer1.start();
                great++;
                com[playindex-1]=1;
                combo++;
                life++;
                tv.setText("Great!");
                comb.setText("combo:"+combo);



            }
            else  if (clicktime[1]>sttime[playindex-1]-300 && clicktime[1]<sttime[playindex-1]+300) {
                tv.setText("GOOD!");
                good++;
                combo = 0;
                life--;

            }
            else
            {
                tv.setText("MISS!");
                combo =0;
                miss++;
                life--;
            }

        }
        else if (playindex>0 && track[playindex-1] == 3)
        {


            if (clicktime[2]>sttime[playindex-1]-80 && clicktime[2]<sttime[playindex-1]+80)
            {
                //playmusic();
                // mediaPlayer1.start();
                com[playindex-1]=1;
                perfect++;
                combo++;
                life++;
              //  Log.v("!!!!!combo!!","is"+combo);
                tv.setText("Perfect!");
                comb.setText("combo:"+combo);



                //   Log.v("!!!!!66666666!!","perfect");
                //  Log.v("!!!!!ctime!!", String.valueOf(clicktime[ind-1]));
                // Log.v("!!!!!time!!", String.valueOf(tim[i]));

            }
            else if (clicktime[2]>sttime[playindex-1]-130 && clicktime[2]<sttime[playindex-1]+130)
            {
                //playmusic();
                // mediaPlayer1.start();
                com[playindex-1]=1;
                combo++;
                great++;
                life++;
                //  Log.v("!!!!!combo!!","is"+combo);
                tv.setText("Great!");
                comb.setText("combo:"+combo);


                //    Log.v("!!!!!combo!!", String.valueOf(combo));
                //   Log.v("!!!!!66666666!!","good");
                //  Log.v("!!!!!time!!", String.valueOf(time));
                // Log.v("!!!!!tim[]!!", String.valueOf(tim[i]));

            }
            else  if (clicktime[2]>sttime[playindex-1]-300 && clicktime[2]<sttime[playindex-1]+300) {
                tv.setText("GOOD!");
                good++;
                combo = 0;
                life--;
                Log.v("!!!!!Miss!!", String.valueOf(combo));
            }
            else
            {
                tv.setText("MISS!");
                miss++;
                life--;
                combo = 0;
            }

        }
        else  if (playindex>0 && track[playindex-1] == 4)
        {


            if (clicktime[3]>sttime[playindex-1]-80 && clicktime[3]<sttime[playindex-1]+80)
            {
                //playmusic();
                com[playindex-1]=1;
                combo++;
                life++;
                perfect++;
                tv.setText("Perfect!");
                comb.setText("combo:"+combo);



                //   Log.v("!!!!!66666666!!","perfect");
                //  Log.v("!!!!!ctime!!", String.valueOf(clicktime[ind-1]));
                // Log.v("!!!!!time!!", String.valueOf(tim[i]));

            }
            else if (clicktime[3]>sttime[playindex-1]-130 && clicktime[3]<sttime[playindex-1]+130)
            {

                com[playindex-1]=1;
                combo++;                //playmusic();
                // mediaPlayer1.start();
                Log.v("!!!!!com!!","is"+com[playindex-1]);
                life++;
                great++;
                tv.setText("Great!");
                comb.setText("combo:"+combo);



                //    Log.v("!!!!!combo!!", String.valueOf(combo));
                //   Log.v("!!!!!66666666!!","good");
                //  Log.v("!!!!!time!!", String.valueOf(time));
                // Log.v("!!!!!tim[]!!", String.valueOf(tim[i]));

            }
            else if (clicktime[3]>sttime[playindex-1]-300 && clicktime[3]<sttime[playindex-1]+300) {
                tv.setText("GOOD!");
                good++;
                combo = 0;
                life--;
                //     Log.v("!!!!!Miss!!", String.valueOf(combo));
            }
            else
            {
                tv.setText("MISS!");
                combo = 0;
                miss++;
                life--;
            }

        }



    }




    private void doTranslationXAnimation(final int index) {
        if(flag == 1)
        {
            final int[] tim=this.getResources().getIntArray(R.array.notetime);
            int[] track=this.getResources().getIntArray(R.array.track);


            if (track[index]-1 == 0)
            {
                butto[index].setX(30);

            }
            else if (track[index]-1 == 1)
            {
                butto[index].setX(210);
            }
            else  if (track[index]-1 == 2)
            {
                butto[index].setX(390);
            }
            else  if (track[index]-1 == 3)
            {
                butto[index].setX(570);
            }

            // butto[0].setVisibility(View.VISIBLE);
            a[index] = ObjectAnimator.ofFloat(butto[index], "translationY", 0, 920);
            a[index].setStartDelay(tim[index]-1800);//1800 2050
            // a[0] = animator.clone();
            //  a[0].setTarget(mStartButton);
            // a[0].setStartDelay(150);
            // a[0].setDuration(3000);
            a[index].setInterpolator(new LinearInterpolator());
            a[index].setDuration(2100);
            a[index].start();

            a[index].addListener(new Animator.AnimatorListener() {
                @Override
                public void onAnimationStart(Animator animation) {
                    butto[index].setVisibility(View.VISIBLE);
                    animtime = time ;
                    // 2737  2952 3182 3886
                    //   Log.e("the time of animation",":"+animtime);



                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    butto[index].setVisibility(View.GONE);
                    playindex++;
                    sttime[index] = time  ;
                    // butto[0].gettime
                    //  Log.e("music time",":"+time);//-26

                    isMiss();
                    setMaxcombo();
                    computeresult();
                    Log.e("index", String.valueOf(index));
                    if (index+1 == notenum)
                    {
                        Log.e("index == notenum", String.valueOf(+index) + notenum);
                        showResult();
                    }



                }

                @Override
                public void onAnimationCancel(Animator animation) {

                }

                @Override
                public void onAnimationRepeat(Animator animation) {

                }
            });
            //hard
        }
        else if (flag == 0)
        {
            final int[] tim=this.getResources().getIntArray(R.array.easynotetime);
            int[] track=this.getResources().getIntArray(R.array.easynote);


            if (track[index]-1 == 0)
            {
                butto[index].setX(30);

            }
            else if (track[index]-1 == 1)
            {
                butto[index].setX(210);
            }
            else  if (track[index]-1 == 2)
            {
                butto[index].setX(390);
            }
            else  if (track[index]-1 == 3)
            {
                butto[index].setX(570);
            }

            // butto[0].setVisibility(View.VISIBLE);
            a[index] = ObjectAnimator.ofFloat(butto[index], "translationY", 0, 920);
            a[index].setStartDelay(tim[index]-1800);//1800 2050
            // a[0] = animator.clone();
            //  a[0].setTarget(mStartButton);
            // a[0].setStartDelay(150);
            // a[0].setDuration(3000);
            a[index].setInterpolator(new LinearInterpolator());
            a[index].setDuration(2100);
            a[index].start();

            a[index].addListener(new Animator.AnimatorListener() {
                @Override
                public void onAnimationStart(Animator animation) {
                    butto[index].setVisibility(View.VISIBLE);
                    animtime = time ;
                    // 2737  2952 3182 3886
                    //   Log.e("the time of animation",":"+animtime);



                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    butto[index].setVisibility(View.GONE);
                    playindex++;
                    sttime[index] = time  ;
                    // butto[0].gettime
                    //  Log.e("music time",":"+time);//-26

                    isMiss();
                    setMaxcombo();
                    computeresult();
                    Log.e("index", String.valueOf(index));
                    if (index+1 == notenum)
                    {
                        Log.e("index == notenum", String.valueOf(+index) + notenum);
                        showResult();
                    }



                }

                @Override
                public void onAnimationCancel(Animator animation) {

                }

                @Override
                public void onAnimationRepeat(Animator animation) {

                }
            });
        }



      //  int tim[] = new int[]{1750,1979,2208,2895,3124,3811,4040,4269,4498,4727,4956,5414,5643,5872,6559,6788,7475,7704,7933 };

     //   Log.e("!!!!!!!!show index","======"+index);


        // a[0].start();


    }


    public void pauseAnimation(){
        for (int i = pauseindex ; i < notenum ;i ++)
        {
            a[i].pause();
        }
    }

    public void restartAnimaton(){
        for (int i = pauseindex ; i < notenum ;i ++)
        {
            a[i].resume();
        }

    }
    public void setMaxcombo(){
       if (combo>maxcombo)
       {
           maxcombo = combo ;
           Log.e("the max combo is",":"+maxcombo);
       }
        if (maxcombo>=0 && maxcombo <51)
        {
            maxlevel = 1 ;
        }
        else if (maxcombo>=51 && maxcombo <101)
        {
            maxlevel = 1.1 ;
        }





    }
    public void startGame()
    {

        mediaPlayer1 = MediaPlayer.create(this,R.raw.first);
        for (int in =0 ;in <notenum ; in++)
        {

            doTranslationXAnimation(in);

            if (state == 1)
            {
                pauseindex = in ;
            }
        }
        mediaPlayer1.start();
    }
   public void showResult(){



       Intent intent = new Intent(GameActivity.this,ShowResult.class);

       int c = (int) score;
       Bundle bundle = new Bundle();
       bundle.putInt("maxcombo", maxcombo);
       bundle.putInt("perfect", perfect);
       bundle.putInt("great", great);
       bundle.putInt("miss", miss);
       bundle.putInt("score", c);
       bundle.putInt("mode", flag);//hard
       intent.putExtras(bundle);
       startActivity(intent);




   }
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode==KeyEvent.KEYCODE_BACK){
            mediaPlayer1.stop();
           Intent in = new Intent(GameActivity.this,SongList.class);
           startActivity(in);
        }
        return true;
    }



}
