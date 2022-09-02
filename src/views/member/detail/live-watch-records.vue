<template>
  <div class="float-left">
    <el-table
      :header-cell-style="{ background: '#f1f2f9' }"
      v-loading="loading"
      :data="list"
      class="float-left"
    >
      <el-table-column label="直播课程">
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
          <span
            v-if="scope.row.watch_record && scope.row.watch_record.length !== 0"
          >
            {{ scope.row.watch_record.progress }}%
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="开始学习时间" :width="200">
        <template slot-scope="scope">
          <span
            v-if="
              scope.row.watch_record &&
              scope.row.watch_record.length !== 0 &&
              scope.row.watch_record.created_at
            "
            >{{ scope.row.watch_record.created_at | dateFormat }}
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="最近一次学习" :width="200">
        <template slot-scope="scope">
          <span
            v-if="
              scope.row.watch_record &&
              scope.row.watch_record.length !== 0 &&
              scope.row.watch_record.updated_at
            "
            >{{ scope.row.watch_record.updated_at | dateFormat }}
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="下节课直播时间" :width="200">
        <template slot-scope="scope">
          <span
            v-if="
              scope.row.watch_record &&
              scope.row.watch_record.length !== 0 &&
              scope.row.watch_record.updated_at
            "
            >{{ scope.row.watch_record.updated_at | dateFormat }}
          </span>
          <span v-else>已结课</span>
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
export default {
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
      this.$api.Member.UserLiveWatchRecords(params).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
  },
};
</script>
