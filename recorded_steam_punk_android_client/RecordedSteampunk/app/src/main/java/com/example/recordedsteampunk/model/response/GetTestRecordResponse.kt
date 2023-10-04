package com.example.recordedsteampunk.model.response

import com.example.recordedsteampunk.model.Test
import com.google.gson.annotations.SerializedName

data class GetTestRecordResponse(
    @SerializedName("tests-per-page")
    var testPerPage: Int,
    @SerializedName("num-pages")
    var numPages: Int,
    var tests: Array<Test>,
    @SerializedName("num-tests")
    var numTests: Int,
    @SerializedName("current-page")
    var currentPage: Int,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as GetTestRecordResponse

        if (testPerPage != other.testPerPage) return false
        if (numPages != other.numPages) return false
        if (!tests.contentEquals(other.tests)) return false
        if (numTests != other.numTests) return false
        if (currentPage != other.currentPage) return false

        return true
    }

    override fun hashCode(): Int {
        var result = testPerPage
        result = 31 * result + numPages
        result = 31 * result + tests.contentHashCode()
        result = 31 * result + numTests
        result = 31 * result + currentPage
        return result
    }
}
