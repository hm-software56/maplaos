<?php

namespace app\models;

use Yii;

/**
 * This is the model class for collection "polygon".
 *
 * @property \MongoDB\BSON\ObjectID|string $_id
 * @property mixed $id
 * @property mixed $latitude
 * @property mixed $longitude
 * @property mixed $provinces_id
 * @property mixed $districts_id
 */
class Polygon extends \yii\mongodb\ActiveRecord
{
    /**
     * {@inheritdoc}
     */
    public static function collectionName()
    {
        return ['maplaosdb', 'polygon'];
    }

    /**
     * {@inheritdoc}
     */
    public function attributes()
    {
        return [
            '_id',
            'id',
            'latitude',
            'longitude',
            'provinces_id',
            'districts_id',
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['id', 'latitude', 'longitude', 'provinces_id', 'districts_id'], 'safe']
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
            'latitude' => 'Latitude',
            'longitude' => 'Longitude',
            'provinces_id' => 'Provinces ID',
            'districts_id' => 'Districts ID',
        ];
    }
    public function getProvinces()
    {
        return $this->hasOne(\app\models\Provinces::className(), ['id' => 'provinces_id']);
    }

}
