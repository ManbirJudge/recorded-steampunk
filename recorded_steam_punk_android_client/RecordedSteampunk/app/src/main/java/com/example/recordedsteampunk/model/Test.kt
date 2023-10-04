package com.example.recordedsteampunk.model

import com.google.gson.annotations.SerializedName

data class Test(
    var id: Int,
    var date: Long,
    var title: String,
    var subject: String,
    var topic: String,
    @SerializedName("total-marks")
    var totalMarks: Float,
    @SerializedName("marks-obtained")
    var marksObtained: Float,
)
