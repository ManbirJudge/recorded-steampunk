package com.example.recordedsteampunk

import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.selection.SelectionPredicates
import androidx.recyclerview.selection.SelectionTracker
import androidx.recyclerview.selection.StorageStrategy
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.example.recordedsteampunk.Utils.Companion.toastIt
import com.example.recordedsteampunk.adapter.TestRecordDetailsLookup
import com.example.recordedsteampunk.adapter.TestRecordItemKeyProvider
import com.example.recordedsteampunk.adapter.TestRecordRecyclerAdapter
import com.example.recordedsteampunk.api.ApiClient
import com.example.recordedsteampunk.databinding.ActivityMainBinding
import com.example.recordedsteampunk.dialog.AddTestDialogFragment
import com.example.recordedsteampunk.model.Test
import com.example.recordedsteampunk.model.body.AddTestBody
import com.example.recordedsteampunk.model.body.DeleteTestsBody
import com.example.recordedsteampunk.model.response.AddTestResponse
import com.example.recordedsteampunk.model.response.DeleteTestsResponse
import com.example.recordedsteampunk.model.response.GetTestRecordResponse
import com.example.recordedsteampunk.model.response.STATUS
import com.google.android.material.floatingactionbutton.FloatingActionButton
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MainActivity : AppCompatActivity() {
    companion object {
        const val TAG = "MainActivity [DEBUG]"
    }

    private lateinit var binding: ActivityMainBinding

    private lateinit var menu: Menu

    private lateinit var apiClient: ApiClient

    private lateinit var testRecordSwipeRefreshLayout: SwipeRefreshLayout

    private lateinit var testRecordRecyclerView: RecyclerView
    private lateinit var testRecordRecyclerAdapter: TestRecordRecyclerAdapter
    private lateinit var testRecordRecyclerSelectionTracker: SelectionTracker<Long>

    private lateinit var addTestFab: FloatingActionButton

    private var testRecord: ArrayList<Test> = arrayListOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // setting up toolbar
        setSupportActionBar(binding.mainToolbar)

        // getting items

        // api setup
        apiClient = ApiClient()

        // setting up recycler view
        testRecordRecyclerView = binding.testRecordRecyclerView

        testRecordRecyclerView.setHasFixedSize(true)
        testRecordRecyclerView.layoutManager = LinearLayoutManager(applicationContext)

        testRecordRecyclerAdapter = TestRecordRecyclerAdapter(testRecord, this)
        testRecordRecyclerView.adapter = testRecordRecyclerAdapter

        testRecordRecyclerSelectionTracker = SelectionTracker.Builder(
            "test-record-selection", testRecordRecyclerView, TestRecordItemKeyProvider(testRecordRecyclerView), TestRecordDetailsLookup(testRecordRecyclerView), StorageStrategy.createLongStorage()
        ).withSelectionPredicate(
            SelectionPredicates.createSelectAnything()
        ).build()
        testRecordRecyclerSelectionTracker.addObserver(object : SelectionTracker.SelectionObserver<Long>() {
            override fun onSelectionChanged() {
                super.onSelectionChanged()

                Log.d(TAG, "Selection changed.")

                val numItems = testRecordRecyclerSelectionTracker.selection.size()

                menu.findItem(R.id.menu_main_action_delete).isVisible = numItems > 0
            }
        })

        testRecordRecyclerAdapter.setTracker(testRecordRecyclerSelectionTracker)

        // setting up swipe refresh layout
        testRecordSwipeRefreshLayout = binding.testRecordSwipeRefreshLayout

        testRecordSwipeRefreshLayout.setOnRefreshListener {
            getTestRecord()
        }

        // setting up add test fab
        addTestFab = binding.addNewTestFab

        addTestFab.setOnClickListener {
            val dialogFrag = AddTestDialogFragment()

            dialogFrag.setListener(object : AddTestDialogFragment.AddTestDialogListener {
                override fun onAddTest(date: Long, title: String, subject: String, topic: String, totalMarks: Float, marksObtained: Float) {
                    apiClient.getApiService().addTest(
                        body = AddTestBody(test = Test(-1, date, title, subject, topic, totalMarks, marksObtained))
                    ).enqueue(object : Callback<AddTestResponse> {
                        override fun onResponse(call: Call<AddTestResponse>, response: Response<AddTestResponse>) {
                            val resBody = response.body()

                            if (resBody != null) {
                                if (STATUS.fromCode(resBody.status) == STATUS.SUCCESS) {
                                    toastIt(resBody.message, this@MainActivity)

                                    testRecord.add(resBody.test!!)
                                    testRecordRecyclerAdapter.notifyItemInserted(testRecord.size - 1)
                                } else {
                                    toastIt("Test cannot be added:\n${resBody.status} - ${resBody.message}", this@MainActivity)
                                }
                            } else {
                                Log.d(TAG, "Add test response body is null.")
                            }
                        }

                        override fun onFailure(call: Call<AddTestResponse>, t: Throwable) {
                            Log.d(TAG, "Adding test failed:\n${t.stackTraceToString()}")
                        }
                    })
                }
            })

            dialogFrag.show(supportFragmentManager, TAG)
        }
    }

    override fun onStart() {
        super.onStart()
        getTestRecord()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)

        this.menu = menu

        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.menu_main_action_settings -> true
            R.id.menu_main_action_delete -> {
                deleteSelectedTests()
                true
            }

            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun getTestRecord() {
        testRecordSwipeRefreshLayout.isRefreshing = true

        apiClient.getApiService().getTestRecord(
            pageNo = 0
        ).enqueue(object : Callback<GetTestRecordResponse> {
            override fun onFailure(call: Call<GetTestRecordResponse>, t: Throwable) {
                t.printStackTrace()
                testRecordSwipeRefreshLayout.isRefreshing = false
            }

            override fun onResponse(
                call: Call<GetTestRecordResponse>, response: Response<GetTestRecordResponse>
            ) {
                val responseBody = response.body()

                if (responseBody != null) {
                    val f1 = testRecord.size

                    testRecord.removeAll(testRecord.toSet())
                    testRecordRecyclerAdapter.notifyItemRangeRemoved(0, f1)

                    testRecord.addAll(responseBody.tests)
                    testRecordRecyclerAdapter.notifyItemRangeRemoved(0, testRecord.size)
                } else {
                    Toast.makeText(this@MainActivity, "Response body is null.", Toast.LENGTH_SHORT).show()
                }

                testRecordSwipeRefreshLayout.isRefreshing = false
            }
        })
    }

    private fun deleteSelectedTests() {
        val selectedTestIds = testRecordRecyclerSelectionTracker.selection.toSet()

        testRecord.removeIf {
            val testId = it.id.toLong()

            if (selectedTestIds.contains(testId)) {
                testRecordRecyclerSelectionTracker.deselect(testId)
                return@removeIf true
            }

            return@removeIf false
        }

        apiClient.getApiService().deleteTests(
            body = DeleteTestsBody(testIds = selectedTestIds.toTypedArray())
        ).enqueue(object : Callback<DeleteTestsResponse> {
            override fun onResponse(call: Call<DeleteTestsResponse>, response: Response<DeleteTestsResponse>) {
                val resBody = response.body()

                if (resBody != null) {
                    if (STATUS.fromCode(resBody.status) == STATUS.SUCCESS) {
                        toastIt(resBody.message, this@MainActivity)
                    } else {
                        toastIt("Tests cannot be deleted.\nServer response: ${resBody.message}", this@MainActivity)
                    }
                } else {
                    toastIt("Response body is null while deleting tests.", this@MainActivity)
                }
            }

            override fun onFailure(call: Call<DeleteTestsResponse>, t: Throwable) {
                toastIt("Deleting tests failed.", this@MainActivity)
            }
        })

        testRecordRecyclerAdapter.notifyDataSetChanged()  // TODO: do not use "notifyDataSetChanged"
    }
}