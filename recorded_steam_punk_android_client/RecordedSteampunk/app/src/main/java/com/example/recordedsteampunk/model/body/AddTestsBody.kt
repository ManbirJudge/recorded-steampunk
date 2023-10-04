package com.example.recordedsteampunk.model.body

import com.example.recordedsteampunk.model.Test

data class AddTestsBody(
    val multiple: Boolean = true,
    var tests: Array<Test>
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as AddTestsBody

        if (multiple != other.multiple) return false
        if (!tests.contentEquals(other.tests)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = multiple.hashCode()
        result = 31 * result + tests.contentHashCode()
        return result
    }
}

