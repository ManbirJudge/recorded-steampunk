package com.example.recordedsteampunk

import android.app.Application
import com.google.android.material.color.DynamicColors

class RecordedSteampunkApp : Application() {
    override fun onCreate() {
        super.onCreate()

        DynamicColors.applyToActivitiesIfAvailable(this)
    }
}