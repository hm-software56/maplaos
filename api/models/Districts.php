<?php

namespace app\models;

use Yii;
use \app\models\base\Districts as BaseDistricts;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "districts".
 */
class Districts extends BaseDistricts
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
