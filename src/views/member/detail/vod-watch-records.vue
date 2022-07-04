<template>
  <div class="float-left">
    <el-table
      :header-cell-style="{ background: '#f1f2f9' }"
      v-loading="loading"
      :data="list"
      class="float-left"
    >
      <el-table-column label="录播课程">
        <template slot-scope="scope">
          <div class="d-flex" v-if="courses[scope.row.course_id]">
            <div>
              <thumb-bar
                :value="courses[scope.row.course_id].thumb"
                :width="120"
                :height="90"
                :border="4"
              ></thumb-bar>
            </div>
            <div class="flex-1 ml-15">
              {{ courses[scope.row.course_id].title }}
            </div>
          </div>
          <span v-else class="c-red">课程不存在</span>
        </template>
      </el-table-column>
      <el-table-column label="课程学习进度" :width="200">
        <template slot-scope="scope">
          <span>{{ scope.row.progress }}%</span>
        </template>
      </el-table-column>
      <el-table-column label="看完" :width="80">
        <template slot-scope="scope">
          <span class="c-red" v-if="scope.row.is_watched === 1">是</span>
          <span v-else>否</span>
        </template>
      </el-table-column>
      <el-table-column label="开始时间" :width="200">
        <template slot-scope="scope">{{
          scope.row.created_at | dateFormat
        }}</template></el-table-column
      >
      <el-table-column label="看完时间" :width="200">
        <template slot-scope="scope">{{
          scope.row.watched_at | dateFormat
        }}</template></el-table-column
      >
      <el-table-column label="课时学习明细" :width="200">
        <template slot-scope="scope">
          <el-link type="primary" @click="showVideoDialog(scope.row)"
            >课时学习</el-link
          >
        </template>
      </el-table-column>
    </el-table>

    <div class="float-left mt-15">
      <el-pagination
        background
        :page-size="pagination.size"
        :current-page="pagination.page"
        layout="prev, pager, next, total"
        @current-change="pageChange"
        :total="total"
      >
      </el-pagination>
    </div>
    <video-table-dialog
      :key="updateId"
      v-if="showAddWin"
      :text="tit"
      :id="updateId"
      :userId="id"
      @close="showAddWin = false"
    ></video-table-dialog>
  </div>
</template>
<script>
import VideoTableDialog from "../components/video-table-dialog";
export default {
  components: {
    VideoTableDialog,
  },
  props: ["id"],
  data() {
    return {
      pagination: {
        page: 1,
        size: 8,
      },
      total: 0,
      list: [],
      courses: [],
      loading: false,
      showAddWin: false,
      tit: null,
      updateId: null,
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    showVideoDialog(item) {
      this.tit = this.courses[item.course_id].title;
      this.updateId = item.course_id;
      this.showAddWin = true;
    },
    pageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.UserVodWatchRecords(this.id, this.pagination).then(
        (res) => {
          this.loading = false;

          this.courses = res.data.courses;
          this.list = res.data.data.data;
          this.total = res.data.data.total;
        }
      );
    },
  },
};
</script>
