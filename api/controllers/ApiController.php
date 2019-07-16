<?php

namespace app\controllers;

use app\models\Provinces;
use yii\web\Response;

class ApiController extends \yii\web\Controller
{
    public function actionGetallprovince()
    {
       $provinces=Provinces::find()->asArray()->all();
       \Yii::$app->response->format = Response::FORMAT_JSON;
       return $provinces;
    }

}

