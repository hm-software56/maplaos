<?php

namespace app\models;

use Yii;

/**
 * This is the model class for table "pv".
 *
 * @property int $OGR_FID
 * @property string $shape
 */
class Pv extends \yii\db\ActiveRecord
{
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'pv';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['OGR_FID'], 'required'],
            [['OGR_FID'], 'integer'],
            [['shape'], 'string'],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'OGR_FID' => 'Ogr Fid',
            'shape' => 'Shape',
        ];
    }
}