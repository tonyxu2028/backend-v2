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
          <div class="d-flex" v-if="scope.row.course.id">
            <div>
              <thumb-bar
                :value="scope.row.course.thumb"
                :width="120"
                :height="90"
                :border="4"
              ></thumb-bar>
            </div>
            <div class="flex-1 ml-15">
              {{ scope.row.course.title }}
            </div>
          </div>
          <span v-else class="c-red">课程不存在</span>
        </template>
      </el-table-column>
      <el-table-column label="课程学习进度" :width="200">
        <template slot-scope="scope">
          <span> {{ scope.row.progress }}% </span>
        </template>
      </el-table-column>
      <el-table-column label="开始学习时间" :width="200">
        <template slot-scope="scope">
          <span>{{ scope.row.created_at | dateFormat }} </span>
        </template>
      </el-table-column>
      <el-table-column label="最近一次学习" :width="200">
        <template slot-scope="scope">
          <span
            v-if="
              scope.row.last_view_video &&
              scope.row.last_view_video.length !== 0 &&
              scope.row.last_view_video.updated_at
            "
            >{{ scope.row.last_view_video.updated_at | dateFormat }}
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="课时学习明细" :width="200">
        <template slot-scope="scope">
          <p-link
            text="课时学习"
            type="primary"
            p="v2.member.course.progress"
            @click="showVideoDialog(scope.row)"
          ></p-link>
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
      this.tit = item.course.title;
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
      let params = {};
      Object.assign(params, this.pagination, { user_id: this.id });
      this.$api.Member.UserVodWatchRecords(params).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
  },
};
</script>
