<?php

namespace app\models;

use Yii;
use \app\models\base\Location as BaseLocation;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location".
 */
class Location extends BaseLocation
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
