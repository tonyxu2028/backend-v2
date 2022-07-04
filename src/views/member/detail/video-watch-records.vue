<template>
  <div class="float-left">
    <el-table
      :header-cell-style="{ background: '#f1f2f9' }"
      v-loading="loading"
      :data="list"
      class="float-left"
    >
      <el-table-column label="课时名称">
        <template slot-scope="scope">
          <span v-if="videos[scope.row.video_id]">
            {{ videos[scope.row.video_id].title }}
          </span>
          <span v-else class="c-red">课时不存在</span>
        </template>
      </el-table-column>
      <el-table-column label="课时时长" width="200">
        <template slot-scope="scope">
          <duration-text
            v-if="!loading"
            :duration="scope.row.watch_seconds"
          ></duration-text>
        </template>
      </el-table-column>
      <el-table-column label="已学时长" width="200">
        <template slot-scope="scope">
          <duration-text
            v-if="!loading"
            :duration="scope.row.watch_seconds"
          ></duration-text>
        </template>
      </el-table-column>
      <el-table-column label="是否学完" :width="200">
        <template slot-scope="scope">
          <span class="c-green" v-if="scope.row.watched_at">已学完</span>
          <span v-else>未学完</span>
        </template>
      </el-table-column>
      <el-table-column label="开始学习时间" :width="200">
        <template slot-scope="scope">{{
          scope.row.created_at | dateFormat
        }}</template></el-table-column
      >
      <el-table-column label="看完时间" :width="200">
        <template slot-scope="scope">{{
          scope.row.watched_at | dateFormat
        }}</template>
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
  </div>
</template>
<script>
import DurationText from "@/components/duration-text";
export default {
  components: {
    DurationText,
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
      videos: [],
      loading: false,
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    pageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.UserVideoWatchRecords(this.id, this.pagination).then(
        (res) => {
          this.loading = false;

          this.videos = res.data.videos;
          this.list = res.data.data.data;
          this.total = res.data.data.total;
        }
      );
    },
  },
};
</script>
