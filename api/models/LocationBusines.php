<?php

namespace app\models;

use Yii;
use \app\models\base\LocationBusines as BaseLocationBusines;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location_busines".
 */
class LocationBusines extends BaseLocationBusines
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
