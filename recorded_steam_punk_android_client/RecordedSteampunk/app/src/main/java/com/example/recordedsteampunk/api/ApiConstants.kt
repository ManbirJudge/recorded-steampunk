package com.example.recordedsteampunk.api

object ApiConstants {
    private const val DEBUG_IP = "192.168.0.119:5000"
    private const val PROD_IP = "UNDEFINED"

    const val HTTP_BASE_URL = "http://${DEBUG_IP}"
    const val HTTP_BASE_URL_ = "http://${DEBUG_IP}/"

    const val STATIC_URL = "static"
    const val MEDIA_URL = "media"

    const val TEST_RECORD_URL = "test-record"
}