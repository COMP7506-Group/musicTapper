package com.example.ylin.myapplication;

import android.database.Cursor;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ListView;
import android.widget.SimpleAdapter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ViewRank extends AppCompatActivity {


    ArrayList<HashMap<String, Object>> listData;
    private ListView listv ;
   // private List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
    private SimpleAdapter simpleAdapter = null;
    DBHelper  db;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.datalist);

        listv = (ListView) findViewById(R.id.lv);

        db = new  DBHelper(this);
        Cursor c = db.getrank();
        int columnsSize = c.getColumnCount();
       // Log.v("!!!!!!!!", String.valueOf(columnsSize));

        listData = new ArrayList<HashMap<String, Object>>();
        // 获取表的内容
        while (c.moveToNext()) {

            HashMap<String, Object> map = new HashMap<String, Object>();
            for (int i = 0; i < columnsSize; i++) {
                map.put("name", c.getString(1));

                Log.v("!!!!!!!!","!!!!!!!!!");
               map.put("score", c.getString(3));
              //  map.put("rank", c.getString(2));
                map.put("max", c.getString(4));
            }
            listData.add(map);
        }


        simpleAdapter = new SimpleAdapter(ViewRank.this, listData, R.layout.items,
                new String[] { "name","score","max"}, new int[] { R.id.name,R.id.score,R.id.max});

        listv.setAdapter(simpleAdapter);


    }



}
