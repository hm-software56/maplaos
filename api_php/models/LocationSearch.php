<?php

namespace app\models;

use Yii;
use \app\models\base\LocationSearch as BaseLocationSearch;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "location_search".
 */
class LocationSearch extends BaseLocationSearch
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
