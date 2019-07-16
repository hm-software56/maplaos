<?php

namespace app\models;

use Yii;
use \app\models\base\Provinces as BaseProvinces;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "provinces".
 */
class Provinces extends BaseProvinces
{

    public function behaviors()
    {
        return ArrayHelper::merge(
            parent::behaviors(),
            [
                # custom behaviors
            ]
        );
    }

    public function rules()
    {
        return ArrayHelper::merge(
            parent::rules(),
            [
                # custom validation rules
            ]
        );
    }
    
}
