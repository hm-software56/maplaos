<?php

namespace app\models;

use Yii;
use \app\models\base\LocationTem as BaseLocationTem;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location_tem".
 */
class LocationTem extends BaseLocationTem
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
