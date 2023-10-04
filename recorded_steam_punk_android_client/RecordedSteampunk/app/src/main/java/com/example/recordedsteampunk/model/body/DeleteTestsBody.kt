package com.example.recordedsteampunk.model.body

import com.google.gson.annotations.SerializedName

data class DeleteTestsBody(
    @SerializedName("test-ids")
    val testIds: Array<Long>
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as DeleteTestsBody

        if (!testIds.contentEquals(other.testIds)) return false

        return true
    }

    override fun hashCode(): Int {
        return testIds.contentHashCode()
    }
}
