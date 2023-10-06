package com.example.recordedsteampunk.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.selection.ItemDetailsLookup
import androidx.recyclerview.selection.SelectionTracker
import androidx.recyclerview.widget.RecyclerView
import com.example.recordedsteampunk.R
import com.example.recordedsteampunk.model.Test
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class TestRecordRecyclerAdapter() : RecyclerView.Adapter<TestRecordRecyclerAdapter.TestViewHolder>() {
    companion object {
        fun getDateFormat() = SimpleDateFormat("dd-MM-yyy", Locale.getDefault())
    }

    private lateinit var tests: ArrayList<Test>
    private var tracker: SelectionTracker<Long>? = null
    private lateinit var context: Context

    init {
        setHasStableIds(true)
    }

    class TestViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var mItemView: View = itemView

        var mTitleText = mItemView.findViewById<TextView>(R.id.item_test_title_text)!!
        var mDateText = mItemView.findViewById<TextView>(R.id.item_test_date_text)!!
        var mSubjectText = mItemView.findViewById<TextView>(R.id.item_test_subject_text)!!
        var mTopicText = mItemView.findViewById<TextView>(R.id.item_test_topic_text)!!
        var mMarksObtainedText = mItemView.findViewById<TextView>(R.id.item_test_marks_obtained_text)!!
        var mTotalMarksText = mItemView.findViewById<TextView>(R.id.item_test_total_marks_text)!!
        var mPercentageText = mItemView.findViewById<TextView>(R.id.item_test_percentage_text)!!

        fun getItemDetails() = object : ItemDetailsLookup.ItemDetails<Long>() {
            override fun getPosition(): Int {
                return bindingAdapterPosition
            }

            override fun getSelectionKey(): Long {
                return bindingAdapter!!.getItemId(bindingAdapterPosition)
            }
        }
    }

    constructor(tests: ArrayList<Test>, context: Context) : this() {
        this@TestRecordRecyclerAdapter.tests = tests
        this@TestRecordRecyclerAdapter.context = context
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): TestViewHolder {
        val layoutInflater = LayoutInflater.from(parent.context)
        val testItem: View = layoutInflater.inflate(R.layout.item_test, parent, false)

        return TestViewHolder(testItem)
    }

    override fun onBindViewHolder(holder: TestViewHolder, position: Int) {
        val test = tests[position]

        tracker?.let {
            holder.mTitleText.text = test.title
            holder.mDateText.text = getDateFormat().format(Date(test.date))
            holder.mSubjectText.text = test.subject
            holder.mTopicText.text = test.topic
            holder.mMarksObtainedText.text = test.marksObtained.toString()
            holder.mTotalMarksText.text = test.totalMarks.toString()
            holder.mPercentageText.text = context.resources.getString(R.string.percentage_text, test.marksObtained / test.totalMarks * 100)

            if (it.isSelected(getItemId(position))) {
                holder.mItemView.alpha = 0.75f
            } else {
                holder.mItemView.alpha = 1f
            }
        }
    }

    override fun getItemCount(): Int {
        return tests.size
    }

    override fun getItemId(position: Int): Long {
        return tests[position].id.toLong()
    }

    fun setTracker(t: SelectionTracker<Long>) {
        tracker = t
    }
}