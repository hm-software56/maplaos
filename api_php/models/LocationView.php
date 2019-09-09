<?php

namespace app\models;

use Yii;
use \app\models\base\LocationView as BaseLocationView;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location_view".
 */
class LocationView extends BaseLocationView
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
