<?php

namespace app\models;

use Yii;

/**
 * This is the model class for table "provincemap".
 *
 * @property int $OGR_FID
 * @property string $SHAPE
 * @property double $bid
 * @property string $pro_code
 * @property string $pname
 * @property string $pname_la
 * @property double $mxdouble
 * @property double $mydouble
 */
class Provincemap extends \yii\db\ActiveRecord
{
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'provincemap';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['OGR_FID', 'SHAPE'], 'required'],
            [['OGR_FID'], 'integer'],
            [['SHAPE'], 'string'],
            [['bid', 'mxdouble', 'mydouble'], 'number'],
            [['pro_code'], 'string', 'max' => 2],
            [['pname'], 'string', 'max' => 50],
            [['pname_la'], 'string', 'max' => 255],
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'OGR_FID' => 'Ogr Fid',
            'SHAPE' => 'Shape',
            'bid' => 'Bid',
            'pro_code' => 'Pro Code',
            'pname' => 'Pname',
            'pname_la' => 'Pname La',
            'mxdouble' => 'Mxdouble',
            'mydouble' => 'Mydouble',
        ];
    }
}
