package com.example.recordedsteampunk.adapter

import android.util.Log
import android.view.MotionEvent
import androidx.recyclerview.selection.ItemDetailsLookup
import androidx.recyclerview.widget.RecyclerView

class TestRecordDetailsLookup(private val mRecyclerView: RecyclerView) : ItemDetailsLookup<Long>() {
    companion object {
        const val TAG = "TestRecordDetailsLookup [DEBUG]"
    }
    override fun getItemDetails(e: MotionEvent): ItemDetails<Long>? {
        Log.d(TAG, "Get item details called.")

        val view = mRecyclerView.findChildViewUnder(e.x, e.y)

        if (view != null) {
            val viewHolder = mRecyclerView.getChildViewHolder(view)
            val testViewHolder = viewHolder as TestRecordRecyclerAdapter.TestViewHolder

            Log.d(TAG, "Something under motion event position: ${testViewHolder.getItemDetails()}")

            return testViewHolder.getItemDetails()
        }

        Log.d(TAG, "Nothing under the motion event position, returning null @ get item details.")
        return null
    }
}