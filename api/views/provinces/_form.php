<?php

use yii\helpers\Html;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $model app\models\Provinces */
/* @var $form yii\widgets\ActiveForm */
?>

<div class="provinces-form">

    <?php $form = ActiveForm::begin(); ?>

    <?= $form->field($model, 'pro_code')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'pro_name')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'pro_name_la')->textInput(['maxlength' => true]) ?>

    <?= $form->field($model, 'latitute')->textInput() ?>

    <?= $form->field($model, 'longtitute')->textInput() ?>

    <div class="form-group">
        <?= Html::submitButton('Save', ['class' => 'btn btn-success']) ?>
    </div>

    <?php ActiveForm::end(); ?>

</div>
