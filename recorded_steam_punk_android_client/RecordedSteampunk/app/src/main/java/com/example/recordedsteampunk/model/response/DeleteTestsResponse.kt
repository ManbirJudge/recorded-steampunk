package com.example.recordedsteampunk.model.response

data class DeleteTestsResponse(
    val status: Int,
    val message: String
)

enum class STATUS(val code: Int) {
    UNKNOWN(-1),
    SUCCESS(0),
    WARNING(1),
    ERROR(2);

    companion object {
        fun fromCode(code: Int) = values().firstOrNull { it.code == code }
    }
}