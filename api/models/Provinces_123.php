<?php

namespace app\models;

use Yii;

/**
 * This is the model class for collection "provinces".
 *
 * @property \MongoDB\BSON\ObjectID|string $_id
 * @property mixed $id
 * @property mixed $pro_code
 * @property mixed $pro_name
 * @property mixed $pro_name_lan
 * @property mixed $latitute
 * @property mixed $longtitute
 */
class Provinces extends \yii\mongodb\ActiveRecord
{
    /**
     * {@inheritdoc}
     */
    public static function collectionName()
    {
        return ['maplaosdb', 'provinces'];
    }

    /**
     * {@inheritdoc}
     */
    public function attributes()
    {
        return [
            '_id',
            'id',
            'pro_code',
            'pro_name',
            'pro_name_lan',
            'latitute',
            'longtitute',
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['id', 'pro_code', 'pro_name', 'pro_name_lan', 'latitute', 'longtitute'], 'safe']
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            '_id' => 'ID',
            'id' => 'Id',
            'pro_code' => 'Pro Code',
            'pro_name' => 'Pro Name',
            'pro_name_lan' => 'Pro Name Lan',
            'latitute' => 'Latitute',
            'longtitute' => 'Longtitute',
        ];
    }
    /**
     * @return \yii\db\ActiveQuery
     */
    public function getPolygons()
    {
        return $this->hasMany(\app\models\Polygon::className(), ['provinces_id' => 'id']);
    }
}
