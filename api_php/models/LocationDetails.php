<?php

namespace app\models;

use Yii;
use \app\models\base\LocationDetails as BaseLocationDetails;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location_details".
 */
class LocationDetails extends BaseLocationDetails
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
