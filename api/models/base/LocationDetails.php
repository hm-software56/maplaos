<?php
// This class was automatically generated by a giiant build task
// You should not change it manually as it will be overwritten on next build

namespace app\models\base;

use Yii;

/**
 * This is the base-model class for table "location_details".
 *
 * @property integer $id
 * @property string $phone
 * @property string $email
 * @property string $details
 * @property integer $location_id
 *
 * @property \app\models\Location $location
 * @property string $aliasModel
 */
abstract class LocationDetails extends \yii\db\ActiveRecord
{



    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'location_details';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['details'], 'string'],
            [['location_id'], 'required'],
            [['location_id'], 'integer'],
            [['phone', 'email'], 'string', 'max' => 255],
            [['location_id'], 'exist', 'skipOnError' => true, 'targetClass' => \app\models\Location::className(), 'targetAttribute' => ['location_id' => 'id']]
        ];
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'phone' => 'Phone',
            'email' => 'Email',
            'details' => 'Details',
            'location_id' => 'Location ID',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getLocation()
    {
        return $this->hasOne(\app\models\Location::className(), ['id' => 'location_id']);
    }




}
