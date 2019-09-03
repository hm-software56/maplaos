<?php

namespace app\models;

use Yii;
use \app\models\base\LocationViewDetails as BaseLocationViewDetails;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location_view_details".
 */
class LocationViewDetails extends BaseLocationViewDetails
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
