<?php

namespace app\models;

use Yii;
use \app\models\base\Polygon as BasePolygon;
use yii\helpers\ArrayHelper;

/**
 * This is the model class for table "polygon".
 */
class Polygon extends BasePolygon
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
