package com.example.recordedsteampunk.model.response

import com.example.recordedsteampunk.model.Test

data class AddTestResponse(
    var status: Int,
    var message: String,
    var index: Int?,
    var test: Test?
)
