package com.example.recordedsteampunk.api

import com.example.recordedsteampunk.model.body.*
import com.example.recordedsteampunk.model.response.*
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.DELETE
import retrofit2.http.GET
import retrofit2.http.HTTP
import retrofit2.http.POST
import retrofit2.http.Path

interface ApiService {
    @GET("${ApiConstants.TEST_RECORD_URL}/{page-no}")
    fun getTestRecord(@Path("page-no") pageNo: Int) : Call<GetTestRecordResponse>
    @GET("${ApiConstants.TEST_RECORD_URL}/{page-no}")
    fun getTests(@Path("page-no") pageNo: Int) : Call<GetTestRecordResponse>

    @POST(ApiConstants.TEST_RECORD_URL)
    fun addTest(@Body body: AddTestBody) : Call<AddTestResponse>

    @POST(ApiConstants.TEST_RECORD_URL)
    fun addTests(@Body body: AddTestsBody) : Call<AddTestsResponse>

    @HTTP(method = "DELETE", path = ApiConstants.TEST_RECORD_URL, hasBody = true)
    fun deleteTests(@Body body: DeleteTestsBody) : Call<DeleteTestsResponse>
}