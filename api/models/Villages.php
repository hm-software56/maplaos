<?php

namespace app\models;

use Yii;
use \app\models\base\Villages as BaseVillages;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "villages".
 */
class Villages extends BaseVillages
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
