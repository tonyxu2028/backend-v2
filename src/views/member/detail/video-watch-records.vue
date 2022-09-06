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
          {{ scope.row.video.title }}
        </template>
      </el-table-column>
      <el-table-column label="课时时长" width="200">
        <template slot-scope="scope">
          <duration-text
            v-if="!loading"
            :duration="scope.row.duration"
          ></duration-text>
        </template>
      </el-table-column>
      <el-table-column label="已学时长" width="200">
        <template slot-scope="scope">
          <template
            v-if="
              typeof scope.row.watch_record['watch_seconds'] !== 'undefined'
            "
          >
            <duration-text
              v-if="!loading"
              :duration="scope.row.watch_record.watch_seconds"
            ></duration-text>
          </template>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="是否学完" :width="200">
        <template slot-scope="scope">
          <span
            class="c-green"
            v-if="
              typeof scope.row.watch_record['watched_at'] !== 'undefined' &&
              scope.row.watch_record.watched_at
            "
            >已学完</span
          >
          <span v-else>未学完</span>
        </template>
      </el-table-column>
      <el-table-column label="开始学习时间" :width="200">
        <template slot-scope="scope"
          ><span
            v-if="
              typeof scope.row.watch_record['created_at'] !== 'undefined' &&
              scope.row.watch_record.created_at
            "
            >{{ scope.row.watch_record.created_at | dateFormat }}</span
          >
          <span v-else>-</span>
        </template></el-table-column
      >
      <el-table-column label="最近一次学习" :width="200">
        <template slot-scope="scope">
          <span
            v-if="
              typeof scope.row.watch_record['updated_at'] !== 'undefined' &&
              scope.row.watch_record.updated_at
            "
            >{{ scope.row.watch_record.updated_at | dateFormat }}</span
          >
          <span v-else>-</span>
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
      let params = {};
      Object.assign(params, this.pagination, { user_id: this.id });
      this.$api.Member.UserVideos(params).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
  },
};
</script>
