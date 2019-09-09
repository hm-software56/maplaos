<?php

namespace app\models;

use Yii;
use \app\models\base\Profile as BaseProfile;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "profile".
 */
class Profile extends BaseProfile
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
