package com.example.ylin.myapplication;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

/**
 * Created by linyu on 2016/11/29.
 */

public class DBHelper {

    private static final String TAG = "DB";// 调试标签

    private static final String DATABASE_NAME = "rank.db";// 数据库名
    SQLiteDatabase db;
    Context context;//应用环境上下文   Activity 是其子类

    DBHelper(Context _context) {
        context=_context;
        db=context.openOrCreateDatabase(DATABASE_NAME, 0, null);
        Log.v(TAG,"db path="+db.getPath());
    }

    /**
     * 建表
     * 数据类型
     * SQLite 3
     *  TEXT    文本
     NUMERIC 数值
     INTEGER 整型
     REAL    小数
     NONE    无类型
     */


    public void CreateTable() {
        try {
            db.execSQL("CREATE TABLE   rank  ( id INTEGER PRIMARY KEY  AUTOINCREMENT,name TEXT, rank INTEGER  , score INTEGER, max INTEGER )");
            Log.v(TAG, "Create Table rank ok");
        } catch (Exception e) {
            //建表失败 或已存在
            Log.v(TAG, "table exists.");
        }
    }
    /**
     * 增加数据

     */
    public boolean save(String name,int score ,int max){
        String sql="";
        try{
            sql="insert into rank values(null,'"+name+"',null,'"+score+"','"+max+"')";
            db.execSQL(sql);
            Log.v(TAG,"insert into rank Successfully !");
            return true;

        }catch(Exception e){
            Log.v(TAG,"insert Table rank ,sql: "+sql);
            return false;
        }
    }

    public void close(){
        db.close();
    }

    public Cursor getrank(){

       return db.rawQuery("select * from rank",null);
    }




}
