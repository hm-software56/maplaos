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
 * @property integer $provinces_id
 * @property integer $districts_id
 * @property integer $villages_id
 * @property integer $location_id
 *
 * @property \app\models\Districts $districts
 * @property \app\models\LocationBusines $location
 * @property \app\models\Provinces $provinces
 * @property \app\models\Villages $villages
 * @property \app\models\Photo[] $photos
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
            [['provinces_id', 'districts_id', 'villages_id', 'location_id'], 'integer'],
            [['phone', 'email'], 'string', 'max' => 255],
            [['districts_id'], 'exist', 'skipOnError' => true, 'targetClass' => \app\models\Districts::className(), 'targetAttribute' => ['districts_id' => 'id']],
            [['location_id'], 'exist', 'skipOnError' => true, 'targetClass' => \app\models\LocationBusines::className(), 'targetAttribute' => ['location_id' => 'id']],
            [['provinces_id'], 'exist', 'skipOnError' => true, 'targetClass' => \app\models\Provinces::className(), 'targetAttribute' => ['provinces_id' => 'id']],
            [['villages_id'], 'exist', 'skipOnError' => true, 'targetClass' => \app\models\Villages::className(), 'targetAttribute' => ['villages_id' => 'id']]
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
            'provinces_id' => 'Provinces ID',
            'districts_id' => 'Districts ID',
            'villages_id' => 'Villages ID',
            'location_id' => 'Location ID',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getDistricts()
    {
        return $this->hasOne(\app\models\Districts::className(), ['id' => 'districts_id']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getLocation()
    {
        return $this->hasOne(\app\models\LocationBusines::className(), ['id' => 'location_id']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getProvinces()
    {
        return $this->hasOne(\app\models\Provinces::className(), ['id' => 'provinces_id']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getVillages()
    {
        return $this->hasOne(\app\models\Villages::className(), ['id' => 'villages_id']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getPhotos()
    {
        return $this->hasMany(\app\models\Photo::className(), ['location_details_id' => 'id']);
    }




}