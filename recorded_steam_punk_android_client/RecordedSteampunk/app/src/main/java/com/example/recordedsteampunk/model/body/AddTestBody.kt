package com.example.recordedsteampunk.model.body

import com.example.recordedsteampunk.model.Test

data class AddTestBody(
    val multiple: Boolean = false,
    var test: Test,
)
