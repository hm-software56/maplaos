<?php

namespace app\controllers;

use app\models\Provinces;
use yii\web\Response;
use app\models\Pv;
use app\models\Polygon;
use yii\db\Query;
use app\models\Dt;
use app\models\Districts;
use app\models\Photo;

class ApiController extends \yii\web\Controller
{
    public function behaviors()
{
    return [
        [
            'class' => 'yii\filters\HttpCache',
        ],
    ];
}

    public function actionGetallprovince()
    {
        ini_set("memory_limit","1000M");
       $provinces=Provinces::find()->joinWith(['polygons'])->asArray()->cache(true)->where(['provinces.id'=>1])->all();
       //$provinces=Provinces::find()->joinWith(['polygons'])->asArray()->cache(true)->all();
       \Yii::$app->response->format = Response::FORMAT_JSON;
       return $provinces;
    }
    public function actionGetlistdistrict()
    {
       $provinces=Districts::find()->asArray()->cache(true)->where(['provinces_id'=>1])->all();
       //$provinces=Provinces::find()->joinWith(['polygons'])->asArray()->cache(true)->all();
       \Yii::$app->response->format = Response::FORMAT_JSON;
       return $provinces;
    }

    public function actionPvpolygon()
    {
        ini_set("memory_limit","1000M");
       $provinces=Pv::find()->all();
       //echo $provinces->shape;
       $ss=0;
       foreach($provinces as $provinces) {
           $a=str_replace('POLYGON((', '', $provinces->shape);
           $a1=str_replace('))', '', $a);
           $arr=explode(",", $a1);
         //  $ss+=count($arr);
         //echo count($arr)."<br/>";
           foreach ($arr as $key=>$as) {
               $pg=new Polygon;
               $arr1=explode(" ", $as);
               $pg->provinces_id=$provinces->OGR_FID;
               $pg->latitude=$arr1[1];
               $pg->longitude=$arr1[0];
               $pg->save();
           }
       }

       echo $ss;
    }

    public function actionDtpolygon()
    {
       // echo phpinfo();exit;
        ini_set("memory_limit","100000M");
       $provinces=Dt::find()->all();
       //echo $provinces->shape;
       $ss=0;
       foreach($provinces as $provinces) {
           $a=str_replace('POLYGON((', '', $provinces->shape);
           $a1=str_replace('))', '', $a);
           $arr=explode(",", $a1);
         //  $ss+=count($arr);
         //echo count($arr)."<br/>";
           foreach ($arr as $key=>$as) {
               $pg=new Polygon;
               $arr1=explode(" ", $as);
               $pg->districts_id=$provinces->OGR_FID;
               $pg->latitude=$arr1[1];
               $pg->longitude=$arr1[0];
               $pg->save();
           // echo $arr1[1].",".$arr1[1];
           // echo "<hr/>";
           }
       }

       echo $ss;
    }

    public function actionLoadimg()
    {
        $photos=[];
        $photo_location=Photo::find()->where(['location_id'=>$_GET['id']])->all();
        if(!empty($photo_location))
        {
            foreach ($photo_location as $photo)
            {
                $photos[]=$photo->photo;
            }
        }else{
            $photos=['noimg.png','noimg.png'];
        }
        \Yii::$app->response->format=Response::FORMAT_JSON;
            return $photos;
    }
}

